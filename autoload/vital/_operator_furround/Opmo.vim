scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:_funcs = {'char' : {'v':'v'}, 'line': {'v':'V'}, 'block': {'v':"\<C-v>"}}

function! s:_knormal(s) abort " {{{
  execute 'keepjumps' 'silent' 'normal!' a:s
endfunction " }}}

function! s:_get_default_reg() abort " {{{
  return &clipboard =~# 'unnamedplus' ? '+'
     \ : &clipboard =~# 'unnamed'     ? '*'
     \ :                                '"'
endfunction " }}}

function! s:_reg_save() abort " {{{
  let reg = s:_get_default_reg()
  let regdic = {}
  for r in [reg]
    let regdic[r] = [getreg(r), getregtype(r)]
  endfor

  return [reg, regdic]
endfunction " }}}

function! s:_reg_restore(regdic) abort " {{{
  for [reg, val] in items(a:regdic)
    call setreg(reg, val[0], val[1])
  endfor
endfunction " }}}

" gettext(motion) {{{
function! s:_funcs.char.gettext(reg) abort " {{{
  call s:_knormal(printf('`[v`]"%sy', a:reg))
  return getreg(a:reg)
endfunction " }}}

function! s:_funcs.line.gettext(reg) abort " {{{
  call s:_knormal(printf('`[V`]"%sy', a:reg))
  return getreg(a:reg)
endfunction " }}}

function! s:_funcs.block.gettext(reg) abort " {{{
  call s:_knormal(printf('gv"%sy', a:reg))
  return getreg(a:reg)
endfunction " }}}

function! s:gettext(motion) abort " {{{
  let fdic = s:_funcs[a:motion]
  let [reg, regdic] = s:_reg_save()
  try
    return fdic.gettext(reg)
  finally
    call s:_reg_restore(regdic)
  endtry
endfunction " }}}
"}}}

" highlight(motion, hlgroup) {{{
function! s:highlight(motion, hlgroup) abort " {{{
  let fdic = s:_funcs[a:motion]
  let [reg, regdic] = s:_reg_save()

  try
    call s:_knormal(printf('`[%s`]"%sy', fdic.v, reg))
    let mids = fdic.highlight(getpos("'["), getpos("']"), a:hlgroup)
    return mids
  finally
    call s:_reg_restore(regdic)
  endtry
"   for m in mids
"     silent! call matchdelete(m)
"   endfor
endfunction " }}}

function! s:_funcs.char.highlight(begin, end, hlgroup) abort " {{{
  if a:begin[1] == a:end[1]
    return [matchadd(a:hlgroup,
    \ printf('\%%%dl\%%>%dc\%%<%dc', a:begin[1], a:begin[2]-1, a:end[2]+1))]
  else
    return [
    \ matchadd(a:hlgroup, printf('\%%%dl\%%>%dc', a:begin[1], a:begin[2]-1)),
    \ matchadd(a:hlgroup, printf('\%%%dl\%%<%dc', a:end[1], a:end[2]+1)),
    \ matchadd(a:hlgroup, printf('\%%>%dl\%%<%dl', a:begin[1], a:end[1]))]
  endif
endfunction " }}}

function! s:_funcs.line.highlight(begin, end, hlgroup) abort " {{{
  return [matchadd(a:hlgroup, printf('\%%>%dl\%%<%dl', a:begin[1]-1, a:end[1]+1))]
endfunction " }}}

function! s:_funcs.block.highlight(begin, end, hlgroup) abort " {{{
  return [matchadd(a:hlgroup,
        \ printf('\%%>%dl\%%<%dl\%%>%dc\%%<%dc',
        \ a:begin[1]-1, a:end[1]+1, a:begin[2]-1, a:end[2]+1))]
endfunction " }}}
"}}}

" replace(motion, str, pos) {{{
function! s:replace(motion, str, ...) abort " {{{
  let fdic = s:_funcs[a:motion]
  let [reg, regdic] = s:_reg_save()

  try
    call setreg(reg, a:str, fdic.v)
    return fdic.replace(reg, get(a:, 1, 0))
  finally
    call s:_reg_restore(regdic)
  endtry
endfunction " }}}

function! s:_funcs.char.replace(reg, ...) abort " {{{
  let end = getpos("']")
  let eline = getline(end[1])
  let p = (len(eline) == end[2]) ? 'p' : 'P'
  call s:_knormal(printf('`[v`]"_d"%s%s', a:reg, p))
endfunction " }}}

function! s:_funcs.line.replace(reg, ...) abort " {{{
  let begin = getpos("'[")
  let end = getpos("']")
  if end[1] == line('$')
    if begin[1] == 1
      " ファイル全体を消してしまったので,
      " もう一度 yank しなおして, '[, '] を設定しなおす
      let p = 'PG"_ddggVG"' . a:reg . 'y'
    else
      let p = 'p'
    endif
  else
    let p = 'P'
  endif
  call s:_knormal(printf('`[V`]"_d"%s%s', a:reg, p))
endfunction " }}}

" operation-replace:
" char 最初の行. あとは切り詰め
" line 直前の行にペースト
" block 頭から. あとは切り詰め. あふれたら後ろに
" }}}

" wrap {{{
function! s:wrap(motion, left, right, ...) abort " {{{
  let fdic = s:_funcs[a:motion]
  let [reg, regdic] = s:_reg_save()

  try
    return fdic.wrap(a:left, a:right, reg, get(a:000, 0, 0))
  finally
    call s:_reg_restore(regdic)
  endtry
endfunction " }}}

function! s:_funcs.char.wrap(left, right, reg, ...) abort " {{{
  call s:_knormal("`[v`]\<Esc>")
  call setreg(a:reg, a:right, 'v')
  call s:_knormal('`>"' . a:reg . 'p')
  call setreg(a:reg, a:left, 'v')
  call s:_knormal('`<"' . a:reg . 'P')
endfunction " }}}

function! s:_funcs.line.wrap(left, right, ...) abort " {{{
  " @TODO
  call s:_knormal(printf("%dGA%s\<Esc>%dGgI%s\<Esc>",
        \ getpos("']")[1], a:right, getpos("'[")[1], a:left))
endfunction " }}}

function! s:_funcs.block.wrap(left, right, reg, pos) abort " {{{
  " 各行, 最初と最後.
  if a:pos < 0
    " 各行について char する.
    " left, right が改行文字をもつと壊れる
    call s:_knormal(printf('gv"%sy', a:reg))
    let spos = getpos("'[")
    let epos = getpos("']")
    let end = str2nr(getregtype(a:reg)[1:]) + spos[2] - 1
    call setreg(a:reg, a:right, 'v')
    for line in range(spos[1], epos[1])
      call setpos('.', [0, line, end, 0])
      if len(getline('.')) >= spos[2]
        call s:_knormal('"' . a:reg . 'p')
      endif
    endfor
    call setreg(a:reg, a:left, 'v')
    for line in range(spos[1], epos[1])
      call setpos('.', [0, line, spos[2], 0])
      if len(getline('.')) >= spos[2]
        call s:_knormal('"' . a:reg . 'P')
      endif
    endfor
  else
    return s:_funcs.char.wrap(a:left, a:right, a:reg)
  endif
endfunction " }}}
" }}}

" insert_before {{{
" }}}

" insert_after {{{
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
