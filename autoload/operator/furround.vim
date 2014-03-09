let s:save_cpo = &cpo
set cpo&vim

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
\ '$' : '$',
\} "}}}

function! s:create_block_tbl(dic)  " {{{
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

function! s:get_pair(str) " {{{
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
      else
        " 対応するペアがいない. 壊れているからわかめ
        return [a:str, s:block[a:str[len(a:str) - 1]]]
      endif
    endif
  endfor
  let r = ''
  for i in range(len(stack)-1, 0, -1)
    let r .= stack[i][1]
  endfor
  return [a:str, r]
endfunction " }}}

function! s:get_block(motion, str) " {{{

  if has_key(s:block, a:str[len(a:str)- 1])
    return s:get_pair(a:str)
  endif

  let pair = []
  if s:get_val('operator_furround_latex', 1)
    let pair = s:get_block_latex(a:motion, a:str)
  endif
  if len(pair) == 0 && s:get_val('operator_furround_xml', 0)
    let pair = s:get_block_xml(a:str)
  endif

  if len(pair) == 0 
    let pair = s:get_val('operator_furround_default_block', ['(', ')'])
  endif

  return [a:str . pair[0], pair[1]]
endfunction " }}}

function! s:input() " {{{
  return input('furround-block: ')
endfunction " }}}

let s:append_block = {} " {{{
function! s:append_block.char(left, right)
  execute 'keepjumps' 'silent' 'normal!' "`[v`]\<Esc>"
  execute 'keepjumps' 'silent' 'normal!' printf("`>a%s\<Esc>`<i%s\<Esc>", 
    \ a:right, a:left)
endfunction " }}}

function! s:append_block.line(left, right) " {{{
  execute 'keepjumps' 'silent' 'normal!' printf("%dGA%s\<Esc>%dGgI%s\<Esc>",
        \ getpos("'[")[1], a:right, getpos("']")[1], a:left)
endfunction " }}}

" @vimlint(EVL102, 1, l:_)
function! s:append_block.block(left, right) " {{{
  let [_, l1, c1, _] = getpos("'[")
  let [_, l2, c2, _] = getpos("']")
  for lnum in range(l1, l2)
    execute 'keepjumps' 'silent' 'normal!'
    \ printf("%dG%d|a%s\<Esc>%d|i%s\<Esc>",
    \ lnum, c2, a:right, c1, a:left)
  endfor
endfunction " }}}

function! operator#furround#append(motion) " {{{
  let use_input = 1
  if (v:register == '' || v:register == '"') &&
  \   s:get_val('operator_furround_use_input', 0)
    let str = s:input()
  else
    let str = ''
  endif
  if str == ''
    let reg = v:register == '' ? '"' : v:register
    execute "let str = @" . reg
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

function! s:repeat_set(str) " {{{
  silent! call repeat#set("\<Plug>(operator-furround-repeat)".a:str."\<CR>", 1)
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
