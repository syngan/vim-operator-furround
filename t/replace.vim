filetype plugin on
runtime! plugin/operator/furround.vim

scriptencoding utf-8

function! s:paste_code(lines)
  put =a:lines
  1 delete _
endfunction

describe 'replace'
  before
    new
    execute "setlocal filetype=foo"
  end

  after
    close!
  end

  it '(tako) -> [tako]'
    call s:paste_code(['(tako)'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-furround-replace-input)a([\<CR>"
    Expect getline(1) == '[tako]'
    Expect line('$') == 1
  end

  it '(tako) -> {''tako''}'
    call s:paste_code(['(tako)'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-furround-replace-input)a({'\<CR>"
    Expect getline(1) == '{''tako''}'
    Expect line('$') == 1
  end

  it '`tako` -> {"tako"}'
    call s:paste_code(['`tako`'])
    normal! gg0
    call setreg('"', '{"')
    execute 'normal' "\<Plug>(operator-furround-replace-reg)f`"
    Expect getline(1) == '{"tako"}'
    Expect line('$') == 1
  end

  it '("tako") -> <{"tako"}>'
    call s:paste_code(['("tako")'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-furround-replace-input)a(<{\<CR>"
    Expect getline(1) == '<{"tako"}>'
    Expect line('$') == 1
  end

  it 'tako(hoge) -> "hoge" does not work'
    call s:paste_code(['tako(hoge)'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-furround-replace-input)f)\"\<CR>"
    Expect getline(1) == 'tako(hoge)'
    Expect line('$') == 1
  end

  it '"" -> {}'
    call s:paste_code(['""'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-furround-replace-input)a\"{\<CR>"
    Expect getline(1) == '{}'
    Expect line('$') == 1
  end

  it '"foo " -> {foo }'
    call s:paste_code(['"foo "'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-furround-replace-input)a\"{\<CR>"
    Expect getline(1) == '{foo }'
    Expect line('$') == 1
  end

end

function! s:rep(pre, suf, input, input_mode)
  " input で動作したら w( になるはず.
  " reg ならカーソル位置が変わるのみ
  let dummy = "w\<CR>"

  if a:input_mode == 0
    execute 'normal' a:pre . "\<Plug>(operator-furround-replace-input)" . a:suf . a:input . "\<CR>"
  elseif a:input_mode == 1
    " f レジスタ指定されたらレジスタで動作
    call setreg('f', a:input)
    call setreg('"', "fooo" . a:input)
    execute 'normal' a:pre . "\"f\<Plug>(operator-furround-replace-input)" . a:suf . dummy
  elseif a:input_mode == 2
    " z レジスタ指定されたらレジスタで動作
    call setreg('z', a:input)
    call setreg('"', "fooo" . a:input)
    call setreg('f', "baao" . a:input)
    execute 'normal' a:pre . "\"z\<Plug>(operator-furround-replace-input)" . a:suf . dummy
  elseif a:input_mode == 3
    " デフォルトはレジスタで動作
    call setreg('"', a:input)
    call setreg('f', "baao" . a:input)
    execute 'normal' a:pre . "\<Plug>(operator-furround-replace-reg)" . a:suf . dummy
  elseif a:input_mode == 4
    call setreg('f', a:input)
    call setreg('"', "fooo" . a:input)
    execute 'normal' a:pre . "\"f\<Plug>(operator-furround-replace-reg)" . a:suf . dummy
  elseif a:input_mode == 5
    " z レジスタ指定されたらレジスタで動作
    call setreg('z', a:input)
    call setreg('"', "fooo" . a:input)
    call setreg('f', "baao" . a:input)
    execute 'normal' a:pre . "\"z\<Plug>(operator-furround-replace-reg)" . a:suf . dummy
  elseif a:input_mode == 6
    " use_input が指定されたら, input で動作
    let g:operator#furround#config = {'foo': {'use_input': 1,
          \ 'merge_default_config' : 1}}
    call setreg('"', "fooo" . a:input)
    call setreg('f', "baao" . a:input)
    execute 'normal' a:pre . "\<Plug>(operator-furround-replace-reg)" . a:suf . a:input . "\<CR>"
  elseif a:input_mode == 7
    " use_input が指定で、空文字入力だと reg で動作
    let g:operator#furround#config = {'foo': {'use_input': 1,
          \ 'merge_default_config' : 1}}
    call setreg('"', a:input)
    call setreg('f', "baao" . a:input)
    execute 'normal' a:pre . "\<Plug>(operator-furround-replace-reg)" . a:suf . dummy
  else
    throw "gogo"
  endif
endfunction

describe 'motion'
  before
    new
    set filetype=foo
    unlet! g:operator#furround#config
    call setreg('"', "")
    call setreg('f', "")
  end

  after
    close!
    unlet! g:operator#furround#config
  end

  for s:i in range(8)
    it 'char-1'
      call s:paste_code(['(foo)', '{baa}', '(doo)'])
      normal! gg
      call s:rep('', 'a(', '<', s:i)
      Expect getline(1) ==# "<foo>"
      Expect getline(2) ==# '{baa}'
      Expect getline(3) ==# '(doo)'
      Expect line('$') == 3
    end
    break

    it 'char-2'
      call s:paste_code(['(foo)', '{baa}', '(doo)'])
      normal! 2G
      call s:rep('', 'a{', 'o<', s:i)
      Expect getline(1) ==# '(foo)'
      Expect getline(2) ==# "o<baa>"
      Expect getline(3) ==# '(doo)'
      Expect line('$') == 3
    end

    it 'char-3'
      call s:paste_code(['(foo)', '{baa}', '(doo)'])
      normal! 3G
      call s:rep('', 'a(', 'o<', s:i)
      Expect getline(1) ==# '(foo)'
      Expect getline(2) ==# '{baa}'
      Expect getline(3) ==# "o<doo>"
      Expect line('$') == 3
    end

    it 'char-(} no pair'
      call s:paste_code(['(foo)', '{baa}', '(doo)'])
      normal! gg
      call s:rep('vjf}', '', 'o<', s:i)
      Expect getline(1) ==# '(foo)'
      Expect getline(2) ==# '{baa}'
      Expect getline(3) ==# '(doo)'
      Expect line('$') == 3
    end

    it 'char-( 3) '
      call s:paste_code(['(foo)', '{baa}', '(doo)'])
      normal! gg
      call s:rep('v2jf)', '', 'o<', s:i)
      execute 'normal' "v2jf)\<Plug>(operator-furround-delete)"
      Expect getline(1) ==# "o<foo)"
      Expect getline(2) ==# '{baa}'
      Expect getline(3) ==# "(doo>"
      Expect line('$') == 3
    end

    it 'char- mid'
      call s:paste_code(['bo (foo) ka', '{baa}', '(doo)'])
      normal! ggf(
      call s:rep('', 'a(', 'o<', s:i)
      Expect getline(1) ==# "bo o<foo> ka"
      Expect getline(2) ==# '{baa}'
      Expect getline(3) ==# "(doo)"
      Expect line('$') == 3
    end

    it 'char- mid+'
      call s:paste_code(['bo (foo) ka', '{baa}', '(doo)'])
      normal! ggf(
      call s:rep('vtk', '', 'o<', s:i)
      Expect getline(1) ==# "bo o<foo>ka"
      Expect getline(2) ==# '{baa}'
      Expect getline(3) ==# "(doo)"
      Expect line('$') == 3
    end

    it 'char- head'
      call s:paste_code(['(foo) boo', '{baa}', '(doo)'])
      normal! ggf(
      call s:rep('', 'a(', 'o<', s:i)
      Expect getline(1) ==# "o<foo> boo"
      Expect getline(2) ==# '{baa}'
      Expect getline(3) ==# "(doo)"
      Expect line('$') == 3
    end

    it 'char- tail'
      call s:paste_code(['boo (foo)', '{baa}', '(doo)'])
      normal! ggf(
      call s:rep('ff', 'a(', 'o<', s:i)
      Expect getline(1) ==# "boo o<foo>"
      Expect getline(2) ==# '{baa}'
      Expect getline(3) ==# "(doo)"
      Expect line('$') == 3
    end

    it 'line-1'
      call s:paste_code(['(foo)', '{baa}', '(doo)'])
      normal! gg
      call s:rep('V', '', 'o<', s:i)
      Expect getline(1) ==# "o<foo>"
      Expect getline(2) ==# '{baa}'
      Expect getline(3) ==# '(doo)'
      Expect line('$') == 3
    end

    it 'line-2'
      call s:paste_code(['(foo)', '{baa}', '(doo)'])
      call s:rep('2GV', '', 'o<', s:i)
      Expect getline(1) ==# '(foo)'
      Expect getline(2) ==# "o<baa>"
      Expect getline(3) ==# '(doo)'
      Expect line('$') == 3
    end

    it 'line-12'
      call s:paste_code(['(foo)', '{baa}', '(doo)'])
      call s:rep('2GVj', '', 'o<', s:i)
      Expect getline(1) ==# '(foo)'
      Expect getline(2) ==# "{baa}"
      Expect getline(3) ==# '(doo)'
      Expect line('$') == 3
    end

    it 'line-123'
      call s:paste_code(['(foo)', '{baa}', '(doooooooooooo)', '(qo)'])
      call s:rep('ggV2j', '', 'o<', s:i)
      Expect getline(1) ==# 'o<foo)'
      Expect getline(2) ==# '{baa}'
      Expect getline(3) ==# "(doooooooooooo>"
      Expect getline(4) ==# "(qo)"
      Expect line('$') == 4
    end

    it 'line-1234'
      call s:paste_code(['(foo)', '{baa}', '(doooooooooooo)', '(qo)'])
      call s:rep('ggV3j', '', 'o<', s:i)
      Expect getline(1) ==# 'o<foo)'
      Expect getline(2) ==# '{baa}'
      Expect getline(3) ==# "(doooooooooooo)"
      Expect getline(4) ==# "(qo>"
      Expect line('$') == 4
    end

    it 'line-34'
      call s:paste_code(['(foo)', '{baa}', '(doooooooooooo)', '(qo)'])
      call s:rep('3GVj', '', 'o<', s:i)
      Expect getline(1) ==# '(foo)'
      Expect getline(2) ==# '{baa}'
      Expect getline(3) ==# "o<doooooooooooo)"
      Expect getline(4) ==# "(qo>"
      Expect line('$') == 4
    end

  endfor
end


" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
