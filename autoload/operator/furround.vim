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
  return get(b:, a:key, get(g:, a:key, a:val))
endfunction " }}}

function! s:get_block(str) " {{{
  let len = len(a:str)

  if has_key(s:block, a:str[len - 1])
    return [a:str, s:block[a:str[len - 1]]]
  endif

  let pair = s:get_val('operator_furround_default_block', ['(', ')'])
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

  let [func, right] = s:get_block(str)

  call s:append_block(a:motion, func, right)
  return
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
