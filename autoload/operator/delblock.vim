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
  endif
endfunction " }}}

function! s:knormal(s) " {{{
  execute 'keepjumps' 'silent' 'normal!' a:s
endfunction " }}}

" default block {{{
if exists('g:operator#delblock#default_config')
  unlockvar! g:operator#delblock#default_config
endif
let g:operator#delblock#default_config = {
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
\     {'start': '\\begin{\s*\(\k\+\*\=\)\s*}\%(\[[^\]\+*]\]\|{[^}]\+}\)*\%(\s*\n\)\=',
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
lockvar! g:operator#delblock#default_config
" }}}

function! s:escape(pattern) " {{{
    return escape(a:pattern, '\/~ .*^[''$')
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
  let blocks = s:get_val('config', 0)
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

  if merge && has_key(g:operator#delblock#default_config, &filetype)
      let block_ft += [g:operator#delblock#default_config[&filetype]]
      let merge = get(g:operator#delblock#default_config[&filetype], 'merge_default_config')
  endif
  if exists('block_user_def')
      let block_ft += [block_user_def]
  endif
  if merge
    let block_ft += [g:operator#delblock#default_config['-']]
  endif

  for b in block_ft
    for pair in b.block
      let c = s:block_del_pair(a:str, pair)
      if c != ''
        return c
      endif
    endfor
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

function! operator#delblock#do(motion) " {{{
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

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
