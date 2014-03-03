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

function! s:get_block(motion, str) " {{{
  let len = len(a:str)

  if has_key(s:block, a:str[len - 1])
    return [a:str, s:block[a:str[len - 1]]]
  endif

  let pair = []
  if s:get_val('operator_furround_latex', 1)
    let pair = s:get_block_latex(a:motion, a:str)
  endif

  if len(pair) == 0 
    let pair = s:get_val('operator_furround_default_block', ['(', ')'])
  endif

  return [a:str . pair[0], pair[1]]
endfunction " }}}

function! s:append_block(motion, left, right) " {{{
  if a:motion ==# 'char' 
    execute 'keepjumps' 'silent' 'normal!' "`[v`]\<Esc>"
    execute 'keepjumps' 'silent' 'normal!' printf("`>a%s\<Esc>`<i%s\<Esc>", 
      \ a:right, a:left)
  else
    execute 'keepjumps' 'silent' 'normal!' printf("%dG$a%s\<Esc>%dG0i%s\<Esc>",
          \ getpos("'[")[1], a:right, getpos("']")[1], a:left)
  endif
endfunction " }}}

function! operator#furround#append(motion) " {{{
  " motion is char/line/block
  if a:motion ==# "block"
    return 0
  endif

  let reg = v:register == '' ? '"' : v:register
  
  let str = ""
  execute "let str = @" . reg
  if str ==# ""
    return 0
  endif

  let [func, right] = s:get_block(a:motion, str)

  call s:append_block(a:motion, func, right)
  return
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
