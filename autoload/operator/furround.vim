let s:save_cpo = &cpo
set cpo&vim

scriptencoding utf-8

function! s:log(_) " {{{
  if s:get('debug', 0)
    silent! call vimconsole#log(a:_)
  endif
endfunction " }}}

" default block {{{
" vim 7.3 では '[^\n]' ではだめらしい.
let s:CR = "\n"
let s:wsc_tex = '\s*\%(%[^' . s:CR . ']*\)\=\n\='  " white space with comment
let s:ws_tex = '\s*\n\='  " white spece
let s:prm_tex = '\%(\[[^' .s:CR. '\]]\+\]\|{[^' .s:CR. '}]\+}\)*' " parameters [] or {}
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
\     {'start': '\\begin\s*{\(\k\+\*\=\)}' . s:prm_tex . s:wsc_tex,
\      'end_expr': '\\end\s*{\1}' . s:wsc_tex,
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
\ 'help' : {
\   'merge_default_config' : 1,
\   'block' : [
\     {'start': '*', 'end': '*'},
\     {'start': '|', 'end': '|'},
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

function! s:escape_n(str, mlist, conv) " {{{
  let s = a:str
  if s =~ '\\[1-9]'
    for i in range(1, min([len(a:mlist)-1, 9]))
      if a:conv
        let s = substitute(s, '\\' . i, '\=s:escape(a:mlist[' . i . '])', 'g')
      else
        let s = substitute(s, '\\' . i, '\=a:mlist[' . i . ']', 'g')
      endif
    endfor
  endif

  return s
endfunction " }}}

function! s:echo(msg) " {{{
  redraw | echo 'furround: ' . a:msg
endfunction " }}}

function! s:is_valid_config() " {{{
  return exists("g:operator#furround#config") &&
  \ type(g:operator#furround#config) == type({})
endfunction " }}}

function! s:get_val(key, val) " {{{
  " g:operator#furround#config から
  " default 値付きの値取得.
  if !s:is_valid_config()
    return a:val
  endif

  let dic = g:operator#furround#config
  for ft in [&filetype, '-']
    if has_key(dic, ft)
      if has_key(dic[ft], a:key)
        return dic[ft][a:key]
      else
        " ファイルタイプの設定があって
        " キーがない場合はデフォルトを設定する.
        " '-' はみにいかない
        return a:val
      endif
    endif
  endfor

  return a:val
endfunction " }}}

function! s:get(key, val) " {{{
  return get(g:, 'operator#furround#' . a:key, a:val)
endfunction " }}}

function! s:get_pair_lhs(str, blocks, idx, slen) " {{{
  let [min, bmin] = [a:slen, {}]
  for b in a:blocks
    let i = match(a:str, b.start, a:idx)
    if i < 0
      continue
    endif

    if i < min
      let [min, bmin] = [i, b]
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

  let pe = s:escape_n(bmin.end, mlist, 0)
  if mlist[0] =~ '\n$'
    let pe = "\n" . pe
  endif

  if has_key(bmin, 'end_expr')
    let pee = s:escape_n(bmin.end_expr, mlist, 1)
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
  let blocks = s:concat(s:get_conf("block", []))
  let stack = []
  let slen = len(a:str)
  let l = 0
  while l < slen
    let pair = s:get_pair_lhs(a:str, blocks, l, slen)
    if len(pair) == 0
      break
    endif
    call s:log(pair)

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
  " #conig[&filetype][key] に a:str があればそれを block とする
  for dic in s:get_conf('key', {})
    if has_key(dic, a:str)
      return dic[a:str]
    endif
  endfor

  return []
endfunction " }}}

function! s:get_block_append(str) " {{{
  " 開括弧がなかった場合には key が登録されているか確認する
  let pair = s:get_pair_from_key(a:str)
  if len(pair) > 0
    return pair
  endif

  let pair = s:get_pair(a:str)
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

function! operator#furround#complete_reg(A, L, P) " {{{
  let fn = s:get_val('complete', 0)
  if type(fn) == type(function('tr'))
    return fn(a:A, a:L, a:P)
  endif
  let l =  type(fn) == type([]) ? fn : []

  let regs = '"0123456789-*+.:%#/'
  let list = map(split(regs, '.\zs'), 's:get_reg_rmcr(v:val)')
  let list = filter(list, 'v:val !~ ''^\s*$'' && v:val !~ ''\n''')
  return  join(l + list, "\n")
endfunction " }}}

:highlight furround_hl_group ctermfg=Blue ctermbg=LightRed
function! s:input(motion, reg) " {{{

  if s:get('highlight', 1)
    call s:knormal(printf('`[%s`]"%sy', s:funcs_motion[a:motion].v, a:reg))
    let hlgroup = s:get('hlgroup', 'furround_hl_group')
    let mids = s:funcs_motion[a:motion].highlight(getpos("'["), getpos("']"), hlgroup)
    :redraw
  else
    let mids = []
  endif

  try
    if s:get('debug', 0)
      let str = 'furround-block-' . a:motion . ': '
    else
      let str = 'furround-block: '
    endif
    return input(str, '', "custom,operator#furround#complete_reg")
  finally
    for m in mids
      silent! call matchdelete(m)
    endfor
  endtry
endfunction " }}}

function! s:knormal(s) " {{{
  execute 'keepjumps' 'silent' 'normal!' a:s
endfunction " }}}

function! s:reg_save() " {{{
  let reg = 'f'
  let regdic = {}
  for r in [reg, '"']
    let regdic[r] = [getreg(r), getregtype(r)]
  endfor

  return [reg, regdic]
endfunction " }}}

function! s:reg_restore(reg) " {{{
  let regdic = a:reg[1]
  for r in [a:reg[0], '"']
    call setreg(r, regdic[r][0], regdic[r][1])
  endfor
endfunction " }}}

let s:funcs_motion = {} " {{{
let s:funcs_motion.char = {
  \ 'v': 'v',
  \ 'support_append':  1,
  \ 'support_delete':  1,
  \ 'support_replace': 1}
let s:funcs_motion.line = {
  \ 'v': 'V',
  \ 'support_append':  1,
  \ 'support_delete':  1,
  \ 'support_replace': 1}
let s:funcs_motion.block = {
  \ 'v': "\<C-v>",
  \ 'support_append':  0,
  \ 'support_delete':  0,
  \ 'support_replace': 0}

function! s:funcs_motion.char.append(left, right, reg) " {{{
  call s:knormal("`[v`]\<Esc>")
  call setreg(a:reg, a:right, 'v')
  call s:knormal('`>"' . a:reg . 'p')
  call setreg(a:reg, a:left, 'v')
  call s:knormal('`<"' . a:reg . 'P')
endfunction " }}}

" @vimlint(EVL103, 1, a:reg)
function! s:funcs_motion.line.append(left, right, reg) " {{{
  call s:knormal(printf("%dGA%s\<Esc>%dGgI%s\<Esc>",
        \ getpos("']")[1], a:right, getpos("'[")[1], a:left))
endfunction " }}}
" @vimlint(EVL103, 0, a:reg)

" @vimlint(EVL103, 1, a:reg)
function! s:funcs_motion.block.append(left, right, reg) " {{{
  " FIXME <C-v>$ に対応できていない
  let [l1, c1] = getpos("'[")[1 : 2]
  let [l2, c2] = getpos("']")[1 : 2]
  for lnum in range(l1, l2)
    call s:knormal(printf("%dG%d|a%s\<Esc>%d|i%s\<Esc>",
    \ lnum, c2, a:right, c1, a:left))
  endfor
endfunction " }}}
" @vimlint(EVL103, 0, a:reg)

function! s:funcs_motion.char.highlight(begin, end, hlgroup) " {{{
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

function! s:funcs_motion.line.highlight(begin, end, hlgroup) " {{{
  return [matchadd(a:hlgroup, printf('\%%>%dl\%%<%dl', a:begin[1]-1, a:end[1]+1))]
endfunction " }}}

function! s:funcs_motion.block.highlight(begin, end, hlgroup) " {{{
  return [matchadd(a:hlgroup,
        \ printf('\%%>%dl\%%<%dl\%%>%dc\%%<%dc',
        \ a:begin[1]-1, a:end[1]+1, a:begin[2]-1, a:end[2]+1))]
endfunction " }}}

" }}}

function! s:get_inputstr(motion, input_mode, vreg, reg) " {{{
  " @param reg 作業レジスタ
  " @param vreg オペレータ実行時に指定された v:register
  if (a:vreg != '' && a:vreg != '"')
    " レジスタが指定されていたはモードにかかわらずレジスタを利用
    let str = getreg(a:vreg)
    return [str, 0]
  elseif a:input_mode
    " レジスタは利用しないので, 即復帰
    let str = s:input(a:motion, a:reg)
    return [str, 1]
  endif

  " s:input() で更新されるため
  " この段階で reg の内容を取得
  let rstr = getreg(a:vreg == '' ? '"' : a:vreg)
  if s:get_val('use_input', 0)
    let str = s:input(a:motion, a:reg)
    if str != ''
      return [str, 1]
    endif
  endif

  return [rstr, 0]
endfunction " }}}

function! s:append(motion, input_mode) " {{{

  call s:log("call append(" . a:motion . "," . a:input_mode . ")")
  let regdata = s:reg_save()

  if !s:funcs_motion[a:motion].support_append
    call s:echo('not support motion=' . a:motion)
    return
  endif

  try
    let [str, use_input] = s:get_inputstr(a:motion, a:input_mode, v:register, regdata[0])
    if str ==# ""
      call s:echo('canceled')
      return 0
    endif

    let [func, right] = s:get_block_append(str)

    call s:funcs_motion[a:motion].append(func, right, regdata[0])
  finally
    call s:reg_restore(regdata)
  endtry

  if use_input
    call s:repeat_set(str, v:count)
  endif
endfunction " }}}

function! operator#furround#append(motion) " {{{
  return s:append(a:motion, 0)
endfunction " }}}

function! operator#furround#appendi(motion) " {{{
  return s:append(a:motion, 1)
endfunction " }}}

function! s:get_conf(key, def) " {{{
  " g:operator#furround#config から List 形式で返す.
  " [user[&ft], default[&ft], user[-], default[-]]
  let blocks = s:is_valid_config() ? g:operator#furround#config : {}

  if has_key(blocks, &filetype)
    let block_ft = [blocks[&filetype]]
    if get(block_ft[0], 'merge_default_config_user', 1) && has_key(blocks, '-')
      let block_user_def = blocks['-']
    endif
    let merge = get(block_ft[0], 'merge_default_config', 1)
  elseif has_key(blocks, '-')
    let block_ft = [blocks['-']]
    let merge = get(block_ft[0], 'merge_default_config', 1)
  else
    let block_ft = []
    let merge = 1
  endif

  if merge && has_key(s:default_config, &filetype)
    let block_ft += [s:default_config[&filetype]]
    let merge = get(s:default_config[&filetype], 'merge_default_config', 1)
  endif

  if exists('block_user_def')
    let block_ft += [block_user_def]
  endif
  if merge
    let block_ft += [s:default_config['-']]
  endif

  " block_bf is a list of dictionaries
  return map(block_ft, 'has_key(v:val, a:key) ? v:val[a:key] : a:def')
endfunction " }}}

function! s:concat(bs) " {{{
  let r = []
  for b in a:bs
    let r += b
  endfor

  return r
endfunction " }}}

function! s:block_del_pair(str, pair) " {{{
  let regexp = get(a:pair, 'regexp', 0)
  let ps = regexp ? a:pair.start : s:escape(a:pair.start)

  let m = match(a:str, ps)

  call s:log("m=" . m . ",=" . string(a:pair))
  if m < -1
    return ''
  endif

  if m > 0 && a:str[0 : m-1] !~ '^\_s*$'
    return ''
  endif

  let ms = matchlist(a:str, a:pair.start, m)
  if len(ms) == 0
    return ''
  endif
  let s = len(ms[0]) + m

  let pe = s:escape_n(a:pair.end, ms, 0)

  if has_key(a:pair, 'end_expr')
    let pee = s:escape_n(a:pair.end_expr, ms, 1)
  else
    let pee = s:escape(pe)
  endif

  let me = match(a:str, pee . '\_s*$', s)
  call s:log("me=" . match(a:str, s:escape(pe)))
  if me < 0
    return ''
  endif

  return a:str[s : me - 1]
endfunction " }}}

function! s:get_block_del(str) " {{{

  for pair in s:concat(s:get_conf("block", []))
    let c = s:block_del_pair(a:str, pair)
    if c != ''
      return c
    endif
  endfor

  return ''
endfunction " }}}

" @vimlint(EVL103, 1, a:spos)
function! s:funcs_motion.char.paste(reg, spos, epos) " {{{
  let eline = getline(a:epos[1])
  let p = (len(eline) == a:epos[2]) ? 'p' : 'P'
  return '"' . a:reg . p
endfunction " }}}
" @vimlint(EVL103, 0, a:spos)

function! s:funcs_motion.line.paste(reg, spos, epos) " {{{
  if a:epos[1] == line('$')
    if a:spos[1] == 1
      " ファイル全体を消してしまったので,
      " もう一度 yank しなおして, '[, '] を設定しなおす
      let ret = 'PG"_ddggVG"' . a:reg . 'y'
    else
      let ret = 'p'
    endif
  else
    let ret = 'P'
  endif
  return '"' . a:reg . ret
endfunction " }}}

function! s:delete_str(reg, motion) " {{{
  let func = s:funcs_motion[a:motion]
  call setreg(a:reg, '', 'v')
  call s:knormal(printf('`[%s`]"%sy', func.v, a:reg))
  let str = getreg(a:reg)
  let str = s:get_block_del(str)
  return str
endfunction " }}}

function! s:paste(reg, str, motion) " {{{
  let func = s:funcs_motion[a:motion]
  call setreg(a:reg, a:str, func.v)
  let p = func.paste(a:reg, getpos("'["), getpos("']"))
  call s:knormal(printf('`[%s`]"_d%s', func.v, p))
endfunction " }}}

function! operator#furround#delete(motion) " {{{
  call s:log("call delete(" . a:motion . ")")
  if !has_key(s:funcs_motion, a:motion)
    return
  endif

  let func = s:funcs_motion[a:motion]
  if !func.support_delete
    call s:echo('not support motion=' . a:motion)
    return
  endif

  let pos = getpos(".")
  let regdata = s:reg_save()

  try
    let reg = regdata[0]

    let str = s:delete_str(reg, a:motion)
    if len(str) == ''
      return 0
    endif

    call s:paste(reg, str, a:motion)

  finally
    call s:reg_restore(regdata)
    call setpos(".", pos)
  endtry
endfunction " }}}

function! s:replace(motion, input_mode) " {{{
  call s:log("call replace(" . a:motion . "," . a:input_mode . ")")
  if !has_key(s:funcs_motion, a:motion)
    return
  endif

  let func = s:funcs_motion[a:motion]
  if !func.support_replace
    call s:echo('not support motion=' . a:motion)
    return
  endif

  let pos = getpos(".")
  let regdata = s:reg_save()

  let vreg = v:register

  try
    let reg = regdata[0]

    let str = s:delete_str(reg, a:motion)
    if len(str) == ''
      return 0
    endif

    call s:reg_restore(regdata)
    let [istr, use_input] = s:get_inputstr(a:motion, a:input_mode, vreg, reg)
    if istr ==# ""
      call s:echo('canceled')
      return 0
    endif

    call s:paste(reg, str, a:motion)
    " なぜここで undo が分離される？
    undoj
    let [ifunc, right] = s:get_block_append(istr)
    call func.append(ifunc, right, regdata[0])

  finally
    call s:reg_restore(regdata)
    call setpos(".", pos)
  endtry

  if use_input
    call s:repeat_set(istr, v:count)
  endif
endfunction " }}}

function! operator#furround#replace(motion) " {{{
  return s:replace(a:motion, 0)
endfunction " }}}

function! operator#furround#replacei(motion) " {{{
  return s:replace(a:motion, 1)
endfunction " }}}

function! s:repeat_set(str, count) " {{{
  silent! call repeat#set("\<Plug>(operator-furround-repeat)".a:str."\<CR>", a:count)
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
