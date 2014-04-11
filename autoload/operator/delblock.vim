let s:save_cpo = &cpo
set cpo&vim

scriptencoding utf-8

function! s:get_val(key, val) " {{{
  " default 値付きの値取得.
  return get(g:, 'operator#delblock#' . a:key, a:val)
endfunction " }}}

function! s:log(_) " {{{
  if s:get_val('debug', 0)
    silent! call vimconsole#log(a:_)
  else
    echo "hohohoi"
  endif
endfunction " }}}

function! s:knormal(s) " {{{
  execute 'keepjumps' 'silent' 'normal!' a:s
endfunction " }}}

" default block {{{
let g:operator#delblock#default_block = {
\ 'merge_default_block' : 0,
\ 'block' : [
\   {'start': '(', 'end': ')'},
\   {'start': '<\(\k\+\)>\(\s\|\n\)*', 'end': '</\1>'},
\   {'start': '{\\\k\+\s\+', 'end': '}'},
\   {'start': '{', 'end': '}'},
\   {'start': '[', 'end': '}'},
\   {'start': '<', 'end': '>'},
\   {'start': '"', 'end': '"'},
\   {'start': "'", 'end': "'"},
\   {'start': '`', 'end': '`'},
\   {'start': '\k\+(', 'end': ')'},
\   {'start': '\\begin{\(\k\+\)}', 'end': '\\end{\1\}'},
\   {'start': '\\\k\+\(\[\k\+\]\)\={', 'end': '}'},
\ ]}
" }}}

" 文字列の末尾が ( だったら, textobj の外まで探しに行く?
" append の場合とちがって, 消したいのは一番外側のみな気がする.
" hoge[tako]('foo')
" hoge[tako](<foo>)
" v:count は考慮すべきかも.
" @vimlint(EVL103, 1, a:blocks)
function! s:get_block_del_(str, blocks, pair) " {{{
  call s:log(a:pair)
  let m = match(a:str, a:pair.start)
  call s:log("m=" . m)
  if m < -1
    return ''
  endif

  if m > 0 && a:str[0 : m-1] !~ '\m^\s*$'
    return ''
  endif

  let ms = matchlist(a:str, a:pair.start, m)
  call s:log(ms)
  if len(ms) == 0
    return ''
  endif
  let s = len(ms[0]) + m

  let pe = a:pair.end
  if pe =~ '\\[1-9]'
    for i in range(1, 9)
      let pe = substitute(pe, '\\' . i, '\=ms[' . i . ']', 'g')
    endfor
  endif

  call s:log(pe)
  let me = match(a:str, pe . '\m\(\s\|\n\)*$', s)
  call s:log(me)
  if me < 0
    return ''
  endif

  return a:str[s : me - 1]
endfunction " }}}
" @vimlint(EVL103, 0, a:blocks)

function! s:get_block_del(str) " {{{
  let blocks = s:get_val('blocks', 0)
  if type(blocks) != type({})
    unlet blocks
    let blocks = {}
  endif

  if has_key(blocks, &filetype)
    let b = blocks[&filetype]
  elseif has_key(blocks, '-')
    let b = blocks['-']
  else
    let b = g:operator#delblock#default_block
  endif

  for pair in b.block
    let c = s:get_block_del_(a:str, b, pair)  
    if c != ''
      return c
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

function! operator#delblock#delete(motion) " {{{
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
  silent! call repeat#set("\<Plug>(operator-delblock-repeat)".a:str."\<CR>", 1)
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
