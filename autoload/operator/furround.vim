let s:save_cpo = &cpo
set cpo&vim

scriptencoding utf-8

function! s:log(_) " {{{
  if get(g:, 'operator#furround#debug', 0)
    silent! call vimconsole#log(a:_)
  endif
endfunction " }}}

" default block {{{
let s:ws_tex = '\%(\s*\%(%.*\)*\n\)\='
let s:prm_tex = '\%(\[[^\]]\+\]\|{[^}]\+}\)*'
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
\     {'start': "`", 'end': "`"},
\   ]},
\ 'tex' : {
\   'merge_default_config' : 1,
\   'block' : [
\     {'start': '\\begin\s*{\(\k\+\*\=\)}' . s:prm_tex . s:ws_tex,
\      'end_expr': '\\end\s*{\1}',
\      'end': '\end{\1}', 'regexp': 1},
\     {'start': '{\\\k\+\s\+', 'end': '}',
\      'regexp': 1, 'comment' : '{\bf xxx}'},
\     {'start': '\\\k\+' . s:prm_tex . '{', 'end': '}',
\      'regexp': 1, 'comment' : '\hoge[xxx]{yyy}'},
\     {'start': '\\verb\*\=\(.\)', 'end': '\1', 'regexp': 1},
\     {'start': '\(\$\$\=\)', 'end': '\1', 'regexp': 1},
\     {'start': '\\[', 'end': '\]', 'regexp': 1},
\     {'start': '\\(', 'end': '\)', 'regexp': 1},
\   ]},
\ 'c' : {
\   'merge_default_config' : 1,
\   'block' : [
\     {'start': '\k\+(', 'end': ')', 'regexp': 1},
\     {'start': '\k\+\[', 'end': ']', 'regexp': 1},
\   ]},
\ 'vim' : {
\   'merge_default_config' : 1,
\   'block' : [
\     {'start': '\([vgslabwt]:\)\?[A-Za-z_][0-9A-Za-z_#.]*(',
\      'end': ')', 'regexp': 1},
\     {'start': '\([vgslabwt]:\)\?[A-Za-z_][0-9A-Za-z_#.]*\[',
\      'end': ']', 'regexp': 1},
\   ]},
\ 'html' : {
\   'merge_default_config' : 1,
\   'block' : [
\     {'start': '<\(\k\+\)\%(\s\+[^>]\+\)*>\(\s\|\n\)*',
\      'end': '</\1>', 'regexp': 1},
\   ]},
\ }
" }}}

function! s:escape(pattern) " {{{
    return escape(a:pattern, '\~ .*^[''$')
endfunction " }}}

function! s:escape_n(str, mlist) " {{{
  let s = a:str
  if s =~ '\\[1-9]'
    for i in range(1, min([len(a:mlist)-1, 9]))
      let s = substitute(s, '\\' . i, '\=a:mlist[' . i . ']', 'g')
    endfor
  endif

  return s
endfunction " }}}

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

function! s:get_pair_lhs(str, blocks, idx, slen) " {{{
  let min = a:slen
  let bmin = {}
  for b in a:blocks
    let i = match(a:str, b.start, a:idx)
    if i < 0
      continue
    endif

    if i < min
      let min = i
      let bmin = b

      if min == a:idx
        break
      endif
    endif
  endfor

  if min == a:slen
    " not found
    return {}
  endif

  let mlist = matchlist(a:str, bmin.start, min)
"  let regexp = get(bmin, 'regexp', 0)

  let pe = s:escape_n(bmin.end, mlist)
  if mlist[0] =~ '\n$'
    let pe = "\n" . pe
  endif

  if has_key(bmin, 'end_expr')
    let pee = s:escape_n(bmin.end_expr, mlist)
  else
    let pee = s:escape(pe)
  endif

  return {
  \ 'index' : min,
  \ 'start_str' : mlist[0],
  \ 'start_len' : len(mlist[0]),
  \ 'end_str' : pe,
  \ 'end_expr' : pee,
  \ }
endfunction " }}}

function! s:get_pair_rhs(str, stack, l, pair_idx) " {{{
  " stack に対する閉じ括弧チェック
  let stack = a:stack
  let l = a:l

  while len(stack) > 0
    " 閉じ括弧チェック
    let mrhs = match(a:str, stack[-1].end_expr, l)
    if mrhs < 0 || mrhs > a:pair_idx
      break
    endif

    let mstr = matchstr(a:str, stack[-1].end_expr, mrhs)
    call remove(stack, -1)
    let l = len(mstr) + mrhs
  endwhile

  return [l, stack]
endfunction " }}}

function! s:get_pair(str) " {{{
  let blocks = s:get_conf()
  let stack = []
  let slen = len(a:str)
  let l = 0
  while l < slen
    let pair = s:get_pair_lhs(a:str, blocks, l, slen)
    if len(pair) == 0
      break
    endif

    let [l, stack] = s:get_pair_rhs(a:str, stack, l, pair.index)
    if l > pair.index
      " 他の閉括弧で開括弧がつぶされた
      continue
    endif

    call add(stack, pair)
    let l = pair.index + pair.start_len
  endwhile

  let [l, stack] = s:get_pair_rhs(a:str, stack, l, slen)

  if len(stack) == 0
    return []
  endif

  let r = ''
  for i in range(len(stack)-1, 0, -1)
    let r .= stack[i].end_str
  endfor
  return ['', r]
endfunction " }}}

function! s:get_pair_from_key(str) " {{{
  if !exists("g:operator#furround#config") ||
  \ type(g:operator#furround#config) != type({})
    return []
  endif

  let blocks = g:operator#furround#config
  for ft in [&filetype, '-']
    if has_key(blocks, ft) 
      if has_key(blocks[ft], 'key') && has_key(blocks[ft]['key'], a:str)
        return blocks[ft]['key'][a:str]
      endif

      if !get(blocks[ft], 'merge_default_config_user', 0)
        break
      endif
    endif
  endfor

  return []
endfunction " }}}

function! s:get_block_append(str) " {{{

  let pair = s:get_pair(a:str)

  if len(pair) == 0
    " 開括弧がなかった場合には key が登録されているか確認する
    let pair = s:get_pair_from_key(a:str)
    if len(pair) > 0
      return pair
    endif
  endif

  if len(pair) == 0
    " 何もなかったらデフォルトの括弧を追加する
    let pair = s:get_val('default_append_block', ['(', ')'])
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
  call setreg('f', a:right, 'v')
  call s:knormal('`>"fp')
  call setreg('f', a:left, 'v')
  call s:knormal('`<"fP')
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

  let [func, right] = s:get_block_append(str)

  let reg = 'f'
  let regdic = {}
  for r in [reg, '"']
    let regdic[r] = [getreg(r), getregtype(r)]
  endfor

  try
    call s:append_block[a:motion](func, right)
  finally
    for r in keys(regdic)
      call setreg(r, regdic[r][0], regdic[r][1])
    endfor
  endtry

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

function! s:get_conf() " {{{
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

  " block_bf is a list of dictionaries
  let bs = map(block_ft, 'has_key(v:val, "block") ? v:val.block : []')

  let r = []
  for b in bs
    let r += b
  endfor

  return r
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

  let pe = a:pair.end
  if regexp && pe =~ '\\[1-9]'
    for i in range(1, min([len(ms)-1, 9]))
      let pe = substitute(pe, '\\' . i, '\=ms[' . i . ']', 'g')
    endfor
  endif

  let me = match(a:str, s:escape(pe) . '\m\(\s\|\n\)*$', s)
  if me < 0
    return ''
  endif

  return a:str[s : me - 1]
endfunction " }}}

function! s:get_block_del(str) " {{{
  for pair in s:get_conf()
    let c = s:block_del_pair(a:str, pair)
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
