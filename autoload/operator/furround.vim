let s:save_cpo = &cpo
set cpo&vim

scriptencoding utf-8

" @vimlint(EVL103, 1, a:_)
function! s:log(_) " {{{
  if s:get_val('operator_furround_debug', 0)
    silent! call vimconsole#log(a:_)
  endif
endfunction " }}}

" default block {{{
let s:block = {
\ '(' : ')',
\ '[' : ']',
\ '<' : '>',
\ '{' : '}',
\ '|' : '|',
\ '"' : '"',
\ '''' : '''',
\ '`' : '`',
\} "}}}

function! s:create_block_tbl(dic)  " {{{
  " 閉じ括弧のテーブルを構築
  let s:block_d = {}

  for k in keys(a:dic)
    if k != a:dic[k]
      let s:block_d[a:dic[k]] = k
    endif
  endfor
endfunction " }}}

" initialize.
call s:create_block_tbl(s:block)

function! s:get_val(key, val) " {{{
  " default 値付きの値取得.
  " b: があったらそれ, なければ g: をみる.
  return get(b:, a:key, get(g:, a:key, a:val))
endfunction " }}}

function! s:get_block_latex(motion, str) " {{{
  " latex 形式の対応
  " \begin{xxx} \begin{yyy} ... が yank されていたら,
  " \end{yyy} \end{xxx} とのペアを作る
  let p = []
  let s = 0
  while 1
    let idx = match(a:str, '\\\(begin\|end\)\s*{\s*\([^}]\+\)\s*}', s)
    if idx < 0
      break
    endif
    let s = idx + 6

    let key = matchstr(a:str, '\\\(begin\|end\)\s*{\s*\([^}]\+\)\s*}', idx)
    let key = substitute(key, '\\\(begin\|end\)\s*{\s*', '', '')
    let key = substitute(key, '\s*}$', '', '')
    let t = match(a:str, '\\begin\s*{\s*\([^}]\+\)\s*}', idx)
    if t == idx
      let p += [key]
    elseif len(p) > 0 && p[-1] ==# key
      call remove(p, -1)
    endif

  endwhile

  if len(p) == 0
    return []
  endif

  let end = ""
  while len(p) > 0
    let t = remove(p, -1)
    if a:motion ==# "line"
      let end .= "\n\\end{" . t . "}"
    else
      let end .= "\\end{" . t . "}"
    endif
  endwhile

  return ['', end]
endfunction " }}}

function! s:get_block_xml(str) " {{{
  " xml 形式の対応
  " <xxx xxxx><yyy yyyyy> ... が yank されていたら,
  " </yyy></xxx> とのペアを作る
  let p = []
  let s = 0
  while 1
    let idx = match(a:str, '<\(/\)\=[^[:space:]>][^>]*>', s)
    if idx < 0
      break
    endif

    let s = idx + 3
    let key = matchstr(a:str, '<\(/\)\=[^[:space:]>][^>]*>', idx)
    let tag = substitute(key, '\s.*', '', '')
    let tag = substitute(tag, '>', '', '')
    if tag[len(tag) - 1] == '/'
      continue
    endif
    let tag = substitute(tag, '<\(/\)\=', '', '')
    if key[1] != '/'
      let p += [tag]
    elseif len(p) > 0 && p[-1] ==# tag
      call remove(p, -1)
    endif

  endwhile

  if len(p) == 0
    return []
  endif

  let end = ""
  while len(p) > 0
    let t = remove(p, -1)
    let end .= "</" . t . ">"
  endwhile

  return ['', end]
endfunction " }}}

function! s:get_pair(str, last) " {{{
  let stack = []
  let l = len(a:str)
  for l in range(len(a:str))
    let s = a:str[l]
    if has_key(s:block, s)
        " 開括弧
      let r = s:block[s]
      if r == s && len(stack) > 0
        let pair = stack[-1]
        if pair[0] == r
          " 始まりと終わりが同じタイプ
          call remove(stack, -1)
        else
          let stack += [[s, r]]
        endif
      else
        let stack += [[s, r]]
      endif
    elseif has_key(s:block_d, s)
      " 閉じ括弧
      if len(stack) > 0 && stack[-1][1] == s
        call remove(stack, -1)
      elseif a:last
        " 対応するペアがいない. 壊れているからわかめ
        return ['', s:block[a:str[len(a:str) - 1]]]
      else
        return []
      endif
    endif
  endfor

  if len(stack) == 0
    return []
  endif

  let r = ''
  for i in range(len(stack)-1, 0, -1)
    let r .= stack[i][1]
  endfor
  return ['', r]
endfunction " }}}

function! s:get_block(motion, str) " {{{

  if has_key(s:block, a:str[len(a:str)- 1])
    let pair = s:get_pair(a:str, 1)
    return [a:str, pair[1]]
  endif

  let pair = []
  if s:get_val('operator_furround_latex', 1)
    let pair = s:get_block_latex(a:motion, a:str)
  endif
  if len(pair) == 0 && s:get_val('operator_furround_xml', 0)
    let pair = s:get_block_xml(a:str)
  endif
  if len(pair) == 0
    let pair = s:get_pair(a:str, 0)
  endif
  if len(pair) == 0
    let pair = s:get_val('operator_furround_default_block', ['(', ')'])
  endif

  return [a:str . pair[0], pair[1]]
endfunction " }}}

function! s:get_reg_rmcr(r) " {{{
  let str = getreg(a:r)
  let len = len(str)
  while len > 1 && str[len - 1] == '\n'
    let str = str[0 : len - 2]
    let len -= 1
  endwhile
  return str
endfunction " }}}

function! operator#furround#complete_reg(...) " {{{
  let regs = '"0123456789abcdefghijklmnopqrstuvwxyz-*+.:%#/'
  let list = map(split(regs, '.\zs'), 's:get_reg_rmcr(v:val)')
  let list = filter(list, 'v:val !~ ''^\s*$'' && v:val !~ ''\n''')
  return  join(list, "\n")
endfunction " }}}

function! s:input() " {{{
  return input('furround-block: ', '', "custom,operator#furround#complete_reg")
endfunction " }}}

function! s:knormal(s) " {{{
  execute 'keepjumps' 'silent' 'normal!' a:s
endfunction " }}}

let s:append_block = {}
function! s:append_block.char(left, right) " {{{
  call s:knormal("`[v`]\<Esc>")
  call s:knormal(printf("`>a%s\<Esc>`<i%s\<Esc>", a:right, a:left))
endfunction " }}}

function! s:append_block.line(left, right) " {{{
  call s:knormal(printf("%dGA%s\<Esc>%dGgI%s\<Esc>",
        \ getpos("'[")[1], a:right, getpos("']")[1], a:left))
endfunction " }}}

function! s:append_block.block(left, right) " {{{
  let [l1, c1] = getpos("'[")[1 : 2]
  let [l2, c2] = getpos("']")[1 : 2]
  for lnum in range(l1, l2)
    call s:knormal(printf("%dG%d|a%s\<Esc>%d|i%s\<Esc>",
    \ lnum, c2, a:right, c1, a:left))
  endfor
endfunction " }}}

function! s:append(motion, input_mode) " {{{
  let use_input = 1
  if a:input_mode
    let str = s:input()
    if str == ''
      return 0
    endif
  elseif (v:register == '' || v:register == '"') &&
  \   s:get_val('operator_furround_use_input', 0)
    let str = s:input()
  else
    let str = ''
  endif
  if str == ''
    let reg = v:register == '' ? '"' : v:register
    let str = getreg(reg)
    let use_input = 0
  endif
  if str ==# ""
    return 0
  endif

  let [func, right] = s:get_block(a:motion, str)
  call s:append_block[a:motion](func, right)

  if use_input
    call s:repeat_set(str)
  endif
endfunction " }}}

function! operator#furround#append(motion) " {{{
  return s:append(a:motion, 0)
endfunction " }}}

function! operator#furround#appendi(motion) " {{{
  return s:append(a:motion, 1)
endfunction " }}}


" 文字列の末尾が ( だったら, textobj の外まで探しに行く?
" append の場合とちがって, 消したいのは一番外側のみな気がする.
" hoge[tako]('foo')
" hoge[tako](<foo>)
" v:count は考慮すべきかも.
function! s:get_block_del(str) " {{{
  let stack = []
  let l = len(a:str)
  let last = []
  for l in range(len(a:str))
    let s = a:str[l]
    if has_key(s:block, s)
        " 開括弧
      let r = s:block[s]
      if r == s && len(stack) > 0
        if stack[-1][0] == r
          " 閉じた
          let last = remove(stack, -1)
        else
          let stack += [[s, r, l]]
        endif
      else
        let stack += [[s, r, l]]
      endif
    elseif has_key(s:block_d, s)
      " 閉じ括弧
      if len(stack) > 0 && stack[-1][1] == s
        let last = remove(stack, -1)
      else
        " 対応するペアがいない. 壊れているからわかめ
      endif
    endif
  endfor

  " 最後のスペースどうすんべ.
  while l >= 0
    if a:str[l] !~ '[[:blank:]\n]'
      break
    endif
    let l -= 1
  endwhile

  if len(last) > 0 && last[1] == a:str[l]
    return last + [l]
  else
    return []
  endif
endfunction " }}}

let s:delf = {}
let s:delf.char = {'v' : 'v'}
let s:delf.line = {'v' : 'V'}

" @vimlint(EVL103, 1, a:spos)
function! s:delf.char.paste(reg, spos, epos, eline) " {{{
  let p = (len(a:eline) == a:epos[2]) ? 'p' : 'P'
  return '"' . a:reg . p
endfunction " }}}
" @vimlint(EVL103, 0, a:spos)

" @vimlint(EVL103, 1, a:eline)
function! s:delf.line.paste(reg, spos, epos, eline) " {{{
  if a:epos[1] == line('$')
    if a:spos[1] == 1
      let ret = 'PG"_dd'
    else
      let ret = 'p'
    endif
  else
    let ret = 'P'
  endif
  return '"' . a:reg . ret
endfunction " }}}
" @vimlint(EVL103, 0, a:eline)

function! operator#furround#delete(motion) " {{{
  if !has_key(s:delf, a:motion)
    return
  endif

  let func = s:delf[a:motion]

  let pos = getpos(".")

  let reg = 'f'
  let regdic = {}
  for r in [reg, '"']
    let regdic[r] = [getreg(r), getregtype(r)]
  endfor

  try
    call setreg(reg, '', 'v')
    let v = func.v
    call s:knormal(printf('`[%s`]"%sy', v, reg))
    let str = getreg(reg)
    let block = s:get_block_del(str)
    if len(block) == 0
      return 0
    endif
    let str = str[block[2]+1 : block[3]-1] . str[block[3]+1 :]

    call setreg(reg, str, v)

    let p = func.paste(reg, getpos("'["), getpos("']"), getline("']"))

    call s:knormal(printf('`[%s`]"_d%s', v, p))
  finally
    for r in keys(regdic)
      call setreg(r, regdic[r][0], regdic[r][1])
    endfor
    call setpos(".", pos)
  endtry
endfunction " }}}

function! s:repeat_set(str) " {{{
  silent! call repeat#set("\<Plug>(operator-furround-repeat)".a:str."\<CR>", 1)
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
