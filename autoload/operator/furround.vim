let s:save_cpo = &cpo
set cpo&vim

let s:block = {
\ '(' : ')',
\ '[' : ']',
\ '<' : '>',
\}

function! operator#furround#append(motion)
  " motion is char/line/block
  if a:motion ==# "block"
    return 0
  endif

  let reg = v:register == '' ? '' : '"' . v:register
  
  let str = ""
  execute "let str = @" . reg
  if str ==# ""
    return 0
  endif

  if has_key(s:block, str[len(str) - 1])
    let right = s:block[str[len(str) - 1]]
    let func = str
  else
    let right = ')'
    let func = str . '('
  endif

  execute 'keepjumps' 'silent' 'normal!' "`[v`]\<Esc>"
  execute 'keepjumps' 'silent' 'normal!' printf("`>a%s\<Esc>`<i%s\<Esc>", right, func)
  return
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
