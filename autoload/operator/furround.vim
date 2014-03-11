let s:save_cpo = &cpo
set cpo&vim

" @vimlint(EVL102, 1, a:_)
function! s:log(_) " {{{
"  call vimconsole#log(a:_)
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
  " default $BCMIU$-$NCM<hF@(B.
  " b: $B$,$"$C$?$i$=$l(B, $B$J$1$l$P(B g: $B$r$_$k(B.
  return get(b:, a:key, get(g:, a:key, a:val))
endfunction " }}}

function! s:get_block_latex(motion, str) " {{{
  " latex $B7A<0$NBP1~(B
  " \begin{xxx} \begin{yyy} ... $B$,(B yank $B$5$l$F$$$?$i(B,
  " \end{yyy} \end{xxx} $B$H$N%Z%"$r:n$k(B
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
  " xml $B7A<0$NBP1~(B
  " <xxx xxxx><yyy yyyyy> ... $B$,(B yank $B$5$l$F$$$?$i(B,
  " </yyy></xxx> $B$H$N%Z%"$r:n$k(B
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
        " $B3+3g8L(B
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
      " $BJD$83g8L(B
      if len(stack) > 0 && stack[-1][1] == s
        call remove(stack, -1)
      else
        " $BBP1~$9$k%Z%"$,$$$J$$(B. $B2u$l$F$$$k$+$i$o$+$a(B
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

function! s:knormal(s) " {{{
  execute 'keepjumps' 'silent' 'normal!' a:s
endfunction " }}}

let s:append_block = {} " {{{
function! s:append_block.char(left, right)
  call s:knormal("`[v`]\<Esc>")
  call s:knormal(printf("`>a%s\<Esc>`<i%s\<Esc>", a:right, a:left))
endfunction " }}}

function! s:append_block.line(left, right) " {{{
  call s:knormal(printf("%dGA%s\<Esc>%dGgI%s\<Esc>",
        \ getpos("'[")[1], a:right, getpos("']")[1], a:left))
endfunction " }}}

" @vimlint(EVL102, 1, l:_)
function! s:append_block.block(left, right) " {{{
  let [_, l1, c1, _] = getpos("'[")
  let [_, l2, c2, _] = getpos("']")
  for lnum in range(l1, l2)
    call s:knormal(printf("%dG%d|a%s\<Esc>%d|i%s\<Esc>",
    \ lnum, c2, a:right, c1, a:left))
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

" $BJ8;zNs$NKvHx$,(B ( $B$@$C$?$i(B, textobj $B$N30$^$GC5$7$K9T$/(B?
" insert $B$N>l9g$H$A$,$C$F(B, $B>C$7$?$$$N$O0lHV30B&$N$_$J5$$,$9$k(B.
" hoge[tako]('foo')
" hoge[tako](<foo>)
" v:count $B$O9MN8$9$Y$-$+$b(B.
function! s:get_block_del(str) " {{{
  let stack = []
  let l = len(a:str)
  let last = []
  for l in range(len(a:str))
    let s = a:str[l]
    if has_key(s:block, s)
        " $B3+3g8L(B
      let r = s:block[s]
      if r == s && len(stack) > 0
        if stack[-1][0] == r
          " $BJD$8$?(B
          let last = remove(stack, -1)
        else
          let stack += [[s, r, l]]
        endif
      else
        let stack += [[s, r, l]]
      endif
    elseif has_key(s:block_d, s)
      " $BJD$83g8L(B
      if len(stack) > 0 && stack[-1][1] == s
        let last = remove(stack, -1)
      else
        " $BBP1~$9$k%Z%"$,$$$J$$(B. $B2u$l$F$$$k$+$i$o$+$a(B
      endif
    endif
  endfor

  " $B:G8e$N%9%Z!<%9$I$&$9$s$Y(B.
  while l >= 0
    if a:str[l] !~ '[[:blank:]\n]'
      break
    endif
    let l -= l
  endwhile

  if len(last) > 0 && last[1] == a:str[l]
    return last + [l]
  else
    return []
  endif
endfunction " }}}

function! operator#furround#delete(motion) " {{{
  if a:motion != 'char'
    return
  endif

  let save_reg = getreg('f')
  let save_regtype = getregtype('f')
  let pos = getpos(".")
  try
    call s:knormal('`[v`]"fy')
    let str = getreg('f')

    call s:log("count=" . v:count1 . "," . v:count)
    let through = 0
    for _ in range(v:count1)
      let block = s:get_block_del(str)
      if len(block) == 0
        break
      endif
      let str = str[block[2]+1 : block[3]-1] . str[block[3]+1 :]
      let through = 1
    endfor

    if through
      call s:knormal(printf('`[v`]"fdi%s', str))
    endif
  finally
    call setreg('f', save_reg, save_regtype)
    call setpos(".", pos)
  endtry
endfunction " }}}

function! s:repeat_set(str) " {{{
  silent! call repeat#set("\<Plug>(operator-furround-repeat)".a:str."\<CR>", 1)
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
