scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" flag: motion: detail (function) {{{
"  n: line : 改行するか. (wrap), eval
"  w: block: 全体をまとめる (wrap)
"  v: block: 垂直方向 (wrap), eval
"  b: block: 下詰め (replace)  eval
"  c: block: あふれたら捨てる (replace)
"  C: block: 足りなかったら削除しない (replace)
" }}}

let s:_funcs = {'char' : {'v':'v'}, 'line': {'v':'V'}, 'block': {'v':"\<C-v>"}}

function! s:_knormal(s) abort " {{{
  execute 'keepjumps' 'silent' 'normal!' a:s
endfunction " }}}

function! s:_reg_save() abort " {{{
  let reg = '"'
  let regdic = {}
  for r in [reg]
    let regdic[r] = [getreg(r), getregtype(r)]
  endfor
  let sel_save = &selection
  let &selection = "inclusive"

  return [reg, regdic, sel_save]
endfunction " }}}

function! s:_reg_restore(regdic) abort " {{{
  for [reg, val] in items(a:regdic[0])
    call setreg(reg, val[0], val[1])
  endfor
  let &selection = a:regdic[1]
endfunction " }}}

function! s:_block_width(reg) abort " {{{
  return str2nr(getregtype(a:reg)[1:])
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
  let [reg; regdic] = s:_reg_save()
  try
    return fdic.gettext(reg)
  finally
    call s:_reg_restore(regdic)
  endtry
endfunction " }}}
"}}}

" highlight(motion, hlgroup, priority...) {{{
function! s:highlight(motion, hlgroup, ...) abort " {{{
  let fdic = s:_funcs[a:motion]
  let [reg; regdic] = s:_reg_save()
  let priority = get(a:, '1', 10)

  try
    let mids = fdic.highlight(reg, getpos("'["), getpos("']"), a:hlgroup, priority)
    return mids
  finally
    call s:_reg_restore(regdic)
  endtry
endfunction " }}}

function! s:_funcs.char.highlight(reg, begin, end, hlgroup, priority) abort " {{{
  call s:_knormal(printf('`[v`]"%sy', a:reg))
  if a:begin[1] == a:end[1]
    return [matchadd(a:hlgroup,
    \ printf('\%%%dl\%%>%dc\%%<%dc', a:begin[1], a:begin[2]-1, a:end[2]+1), a:priority)]
  else
    return [
    \ matchadd(a:hlgroup, printf('\%%%dl\%%>%dc', a:begin[1], a:begin[2]-1), a:priority),
    \ matchadd(a:hlgroup, printf('\%%%dl\%%<%dc', a:end[1], a:end[2]+1), a:priority),
    \ matchadd(a:hlgroup, printf('\%%>%dl\%%<%dl', a:begin[1], a:end[1]), a:priority)]
  endif
endfunction " }}}

function! s:_funcs.line.highlight(reg, begin, end, hlgroup, priority) abort " {{{
  call s:_knormal(printf('`[V`]"%sy', a:reg))
  return [matchadd(a:hlgroup, printf('\%%>%dl\%%<%dl', a:begin[1]-1, a:end[1]+1), a:priority)]
endfunction " }}}

function! s:_funcs.block.highlight(reg, begin, end, hlgroup, priority) abort " {{{
  call s:_knormal(printf('gv"%sy', a:reg))
  let width = s:_block_width(a:reg)
  echomsg width
  return [matchadd(a:hlgroup,
        \ printf('\%%>%dl\%%<%dl\%%>%dc\%%<%dc',
        \ a:begin[1]-1, a:end[1]+1, a:begin[2]-1, a:begin[2]+width), a:priority)]
endfunction " }}}
"}}}

function! s:unhighlight(mids) abort " {{{
  for m in a:mids
    silent! call matchdelete(m)
  endfor
endfunction " }}}

" replace(motion, str, flags) {{{
function! s:replace(motion, str, ...) abort " {{{
  let fdic = s:_funcs[a:motion]
  let [reg; regdic] = s:_reg_save()

  try
    return fdic.replace(a:str, reg, get(a:000, 0, ''))
  finally
    call s:_reg_restore(regdic)
  endtry
endfunction " }}}

function! s:_funcs.char.replace(str, reg, ...) abort " {{{
  call setreg(a:reg, a:str, 'v')
  let end = getpos("']")
  let eline = getline(end[1])
  if len(eline) > end[2]
    let p = 'P'
  else
    let p = 'p'

    if len(eline) < end[2]
      " 手元では起きないけど, travis で死んだ.
      let end[2] = len(eline)
      call setpos("']", end)
    endif
  endif

  call s:_knormal(printf('`[v`]"_d"%s%s', a:reg, p))
endfunction " }}}

function! s:_funcs.line.replace(str, reg, ...) abort " {{{
  call setreg(a:reg, a:str, 'V')
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

" c.f. operation-replace:
" char 最初の行. あとは切り詰め
" line 直前の行にペースト
" block 頭から. あとは切り詰め. あふれたら後ろに
function! s:_funcs.block.replace(str, reg, flags) abort " {{{
  call s:_knormal('gv"' . a:reg . 'y')
  let spos = getpos("'[")
  let epos = getpos("']")
  let width = s:_block_width(a:reg)
  let strs = split(a:str, "\n")
  if epos[1] - spos[1] + 1 <= len(strs)
    if a:flags =~# 'c'
      " あふれは捨てる
      let t = spos[1]
      let b = epos[1]
      if a:flags =~# 'b'
        let strs = strs[len(strs) - (b - t + 1) :]
      endif
    else
      " 下に上書きしていく.
      let t = spos[1]
      let b = spos[1] + len(strs) - 1
      if b > line('$')
        for i in range(b - line('$'))
          call append('$', repeat(' ', spos[2]))
        endfor
      endif
    endif
  elseif a:flags =~# 'C'
    " 不足分は何もしない
    if a:flags =~# 'b'
      " bottom
      let t = epos[1] - len(strs) + 1
      let b = epos[1]
    else " flag =~# 't' or '' (default)
      " top
      let t = spos[1]
      let b = spos[1] + len(strs) - 1
    endif
  else
    " 不足分は空文字に
    let t = spos[1]
    let b = epos[1]
    if a:flags =~# 'b'
      let strs = repeat([''], epos[1] - spos[1] + 1 - len(strs)) + strs
    else
      let strs = strs + repeat([''], epos[1] - spos[1] + 1 - len(strs))
    endif
  endif
  let end = width + spos[2] - 1

  for i in range(b - t + 1)
    call setpos('.', [0, i + t, spos[2], 0])
    call setreg(a:reg, strs[i], 'v')
    if len(getline('.')) < end
      call s:_knormal(printf('v$h"_d"%sp', a:reg))
    else
      call s:_knormal(printf('v%dl"_d"%sP', width - 1, a:reg))
    endif
  endfor
endfunction " }}}
" }}}

" wrap {{{
function! s:wrap(motion, left, right, ...) abort " {{{
  let fdic = s:_funcs[a:motion]
  let [reg; regdic] = s:_reg_save()

  try
    return fdic.wrap(a:left, a:right, reg, get(a:000, 0, ''))
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

function! s:_funcs.line.wrap(left, right, reg, flags) abort " {{{
  let v = (a:flags =~# 'n') ? 'V' : 'v'

  call s:_knormal("`[V`]\<Esc>")
  if a:right !=# ''
    call setreg(a:reg, a:right, v)
    call s:_knormal('`>"' . a:reg . 'p')
  endif
  if a:left !=# ''
    call setreg(a:reg, a:left, v)
    call s:_knormal('`<"' . a:reg . 'P')
  endif
" call s:_knormal(printf("%dGA%s\<Esc>%dGgI%s\<Esc>",
"       \ getpos("']")[1], a:right, getpos("'[")[1], a:left))
endfunction " }}}

function! s:_funcs.block.wrap(left, right, reg, flags) abort " {{{
  if a:flags =~# 'v'
    return s:block_wrap_vertical(a:left, a:right, a:reg)
  elseif a:flags =~# 'w'
    " whole 最初と最後.
    return s:_funcs.char.wrap(a:left, a:right, a:reg)
  else
    " 各行
    return s:block_wrap_eachline(a:left, a:right, a:reg)
  endif
endfunction " }}}

function! s:block_wrap_eachline(left, right, reg) abort " {{{
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
endfunction " }}}

function! s:block_wrap_vertical(left, right, reg) abort " {{{
  call s:_knormal(printf('gv"%sy', a:reg))
  let spos = getpos("'[")
  let blank = repeat(' ', spos[1]-1)

  if a:right !=# ''
    call setreg(a:reg, blank . a:right, 'V')
    call s:_knormal('`>"' . a:reg . 'p')
  endif
  if a:left !=# ''
    call setreg(a:reg, blank . a:left, 'V')
    call s:_knormal('`<"' . a:reg . 'P')
  endif
endfunction " }}}
" }}}

function! s:insert_before(motion, str, ...) abort " {{{
  return call(function('s:wrap'), [a:motion, a:str, ''] + a:000)
endfunction " }}}

function! s:insert_after(motion, str, ...) abort " {{{
  return call(function('s:wrap'), [a:motion, '', a:str] + a:000)
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
