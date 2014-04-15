let s:save_cpo = &cpo
set cpo&vim

scriptencoding utf-8

" @vimlint(EVL103, 1, a:_)
function! s:log(_) " {{{
  if get(g:, 'operator#furround#debug', 0)
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

" default block {{{
if exists('s:default_config')
  unlockvar! s:default_config
endif
let s:default_config = {
\ '-' : {
\   'merge_default_config' : 0,
\   'block' : [
\     {'start': '(', 'end': ')'},
\     {'start': '{', 'end': '}'},
\     {'start': '[', 'end': ']'},
\     {'start': '<', 'end': '>'},
\     {'start': '"', 'end': '"'},
\     {'start': "'", 'end': "'"},
\   ]},
\ 'tex' : {
\   'merge_default_config' : 1,
\   'block' : [
\     {'start': '\\begin{\s*\(\k\+\*\=\)\s*}\%(\[[^\]]\+\]\|{[^}]\+}\)*\%(\s*\n\)\=',
\      'end': '\\end{\1}', 'regexp': 1},
\     {'start': '{\\\k\+\s\+', 'end': '}',
\      'regexp': 1, 'comment' : '{\bf xxx}'},
\     {'start': '\\\k\+\(\[[^\]]\+\]\|{[^}]\+}\)*{', 'end': '}',
\      'regexp': 1, 'comment' : '\hoge[xxx]{yyy}'},
\     {'start': '\\verb\*\=\(.\)', 'end': '\1', 'regexp': 1},
\     {'start': '\(\$\$\=\)', 'end': '\1', 'regexp': 1},
\     {'start': '\\[', 'end': '\\]', 'regexp': 1},
\     {'start': '\\(', 'end': '\\)', 'regexp': 1},
\   ]},
\ 'c' : {
\   'merge_default_config' : 1,
\   'block' : [
\     {'start': '\k\+(', 'end': ')', 'regexp': 1},
\     {'start': '\k\+\[', 'end': '\]', 'regexp': 1},
\   ]},
\ 'vim' : {
\   'merge_default_config' : 1,
\   'block' : [
\     {'start': '\([vgslabwt]:\)\?[A-Za-z_][0-9A-Za-z_#.]*(', 'end': ')', 'regexp': 1},
\     {'start': '\([vgslabwt]:\)\?[A-Za-z_][0-9A-Za-z_#.]*\[', 'end': '\]', 'regexp': 1},
\   ]},
\ 'html' : {
\   'merge_default_config' : 1,
\   'block' : [
\     {'start': '<\(\k\+\)>\(\s\|\n\)*', 'end': '</\1>', 'regexp': 1},
\   ]},
\ }
lockvar! s:default_config
" }}}

function! s:escape(pattern) " {{{
    return escape(a:pattern, '\/~ .*^[''$')
endfunction " }}}

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
  if ! exists("g:operator#furround#config")
    return a:val
  endif

  let dic = g:operator#furround#config
  for ft in [&filetype, '-']
    if has_key(dic, ft) && has_key(dic[ft], a:key)
      return dic[ft][a:key]
    endif
  endfor

  return a:val
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
  if s:get_val('latex', 1)
    let pair = s:get_block_latex(a:motion, a:str)
    call s:log(pair)
  endif
  if len(pair) == 0 && s:get_val('xml', 0)
    let pair = s:get_block_xml(a:str)
  endif
  if len(pair) == 0
    let pair = s:get_pair(a:str, 0)
  endif
  if len(pair) == 0
    let pair = s:get_val('append_block', ['(', ')'])
    call s:log(pair)
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
        \ getpos("']")[1], a:right, getpos("'[")[1], a:left))
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
  \   s:get_val('use_input', 0)
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

  call s:log("get_block[" . a:motion . "[=" . string([func, right, a:motion, str]))
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

function! s:block_del_pair(str, pair) " {{{
  let regexp = get(a:pair, 'regexp', 0)
  let ps = regexp ? a:pair.start : s:escape(a:pair.start)

  let m = match(a:str, ps)
  if m < -1
    return ''
  endif

  if m > 0 && a:str[0 : m-1] !~ '\m^\s*$'
    return ''
  endif

  let ms = matchlist(a:str, a:pair.start, m)
  if len(ms) == 0
    return ''
  endif
  let s = len(ms[0]) + m

  let pe = regexp ? a:pair.end : s:escape(a:pair.end)
  if regexp && pe =~ '\\[1-9]'
    for i in range(1, 9)
      let pe = substitute(pe, '\\' . i, '\=ms[' . i . ']', 'g')
    endfor
  endif

  let me = match(a:str, pe . '\m\(\s\|\n\)*$', s)
  if me < 0
    return ''
  endif

  return a:str[s : me - 1]
endfunction " }}}

function! s:get_block_del(str) " {{{
  let blocks = exists("g:operator#furround#config") ?
        \ g:operator#furround#config : 0
  if type(blocks) != type({})
    unlet blocks
    let blocks = {}
  endif

  if has_key(blocks, &filetype)
    let block_ft = [blocks[&filetype]]
    if get(block_ft[0], 'merge_default_config_user', 0) && has_key(blocks, '-')
      let block_user_def = blocks['-']
    endif
    let merge = get(block_ft[0], 'merge_default_config', 0)
  elseif has_key(blocks, '-')
    let block_ft = [blocks['-']]
    let merge = get(block_ft[0], 'merge_default_config', 0)
  else
    let block_ft = []
    let merge = 1
  endif

  if merge && has_key(s:default_config, &filetype)
      let block_ft += [s:default_config[&filetype]]
      let merge = get(s:default_config[&filetype], 'merge_default_config')
  endif
  if exists('block_user_def')
      let block_ft += [block_user_def]
  endif
  if merge
    let block_ft += [s:default_config['-']]
  endif

  for b in block_ft
    if has_key(b, "block")
      for pair in b.block
        let c = s:block_del_pair(a:str, pair)
        if c != ''
          return c
        endif
      endfor
    else
      call s:log(b)
    endif
  endfor

  return ''
endfunction " }}}

let s:del_funcs = {}
let s:del_funcs.char = {'v' : 'v'}
let s:del_funcs.line = {'v' : 'V'}

" @vimlint(EVL103, 1, a:spos)
function! s:del_funcs.char.paste(reg, spos, epos, eline) " {{{
  let p = (len(a:eline) == a:epos[2]) ? 'p' : 'P'
  return '"' . a:reg . p
endfunction " }}}
" @vimlint(EVL103, 0, a:spos)

" @vimlint(EVL103, 1, a:eline)
function! s:del_funcs.line.paste(reg, spos, epos, eline) " {{{
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
  if !has_key(s:del_funcs, a:motion)
    return
  endif

  let func = s:del_funcs[a:motion]

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
    let str = s:get_block_del(str)
    if len(str) == ''
      return 0
    endif

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
