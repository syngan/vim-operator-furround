filetype plugin on
runtime! plugin/operator/*.vim

scriptencoding utf-8

function! s:paste_code(lines)
  put =a:lines
  1 delete _
endfunction

for g:fp in ['', 'tex', 'c', 'vim']
  describe 'del-pair'
    before
      new
      execute "setlocal filetype=" . g:fp
    end

    after
      close!
    end

    it '(tako)'
      call s:paste_code(['(tako)'])
      normal! gg0
      execute 'normal' "\<Plug>(operator-furround-delete)f)"
      Expect getline(1) == 'tako'
    end

    it '{tako}'
      call s:paste_code(['{tako}'])
      normal! gg0
      execute 'normal' "\<Plug>(operator-furround-delete)f}"
      Expect getline(1) == 'tako'
    end

    it '[tako]'
      call s:paste_code(['[tako]'])
      normal! gg0
      execute 'normal' "\<Plug>(operator-furround-delete)f]"
      Expect getline(1) == 'tako'
    end

    it '"tako"'
      call s:paste_code(['"tako"'])
      normal! gg0
      execute 'normal' "\<Plug>(operator-furround-delete)f\""
      Expect getline(1) == 'tako'
    end

    it '<tako>'
      call s:paste_code(['<tako>'])
      normal! gg0
      execute 'normal' "\<Plug>(operator-furround-delete)f>"
      Expect getline(1) == 'tako'
    end

    it '''tako'''
      call s:paste_code(['''tako'''])
      normal! gg0
      execute 'normal' "\<Plug>(operator-furround-delete)f'"
      Expect getline(1) == 'tako'
    end
  end
endfor


describe 'motion-delete'
  before
    new
    set filetype=foo
    unlet! g:operator#furround#config
  end

  after
    close!
    unlet! g:operator#furround#config
  end

  it 'char-1'
    call s:paste_code(['(foo)', '{baa}', '(doo)'])
    normal! gg
    execute 'normal' "\<Plug>(operator-furround-delete)a("
    Expect getline(1) ==# "foo"
    Expect getline(2) ==# '{baa}'
    Expect getline(3) ==# '(doo)'
    Expect line('$') == 3
  end

  it 'char-2'
    call s:paste_code(['(foo)', '{baa}', '(doo)'])
    normal! 2G
    execute 'normal' "\<Plug>(operator-furround-delete)a{"
    Expect getline(1) ==# '(foo)'
    Expect getline(2) ==# "baa"
    Expect getline(3) ==# '(doo)'
    Expect line('$') == 3
  end

  it 'char-3'
    call s:paste_code(['(foo)', '{baa}', '(doo)'])
    normal! 3G
    execute 'normal' "\<Plug>(operator-furround-delete)a("
    Expect getline(1) ==# '(foo)'
    Expect getline(2) ==# '{baa}'
    Expect getline(3) ==# "doo"
    Expect line('$') == 3
  end

  it 'char-(} no pair'
    call s:paste_code(['(foo)', '{baa}', '(doo)'])
    normal! gg
    execute 'normal' "vjf}\<Plug>(operator-furround-delete)"
    Expect getline(1) ==# '(foo)'
    Expect getline(2) ==# '{baa}'
    Expect getline(3) ==# '(doo)'
    Expect line('$') == 3
  end

  it 'char-( 3) '
    call s:paste_code(['(foo)', '{baa}', '(doo)'])
    normal! gg
    execute 'normal' "v2jf)\<Plug>(operator-furround-delete)"
    Expect getline(1) ==# "foo)"
    Expect getline(2) ==# '{baa}'
    Expect getline(3) ==# "(doo"
    Expect line('$') == 3
  end

  it 'char- bo ka'
    call s:paste_code(['bo (foo) ka', '{baa}', '(doo)'])
    normal! ggf(
    execute 'normal' "\<Plug>(operator-furround-delete)a("
    Expect getline(1) ==# "bo foo ka"
    Expect getline(2) ==# '{baa}'
    Expect getline(3) ==# "(doo)"
    Expect line('$') == 3
  end

  it 'char- bo ka+'
    call s:paste_code(['bo (foo) ka', '{baa}', '(doo)'])
    normal! ggf(
    execute 'normal' "vtk\<Plug>(operator-furround-delete)"
    Expect getline(1) ==# "bo fooka"
    Expect getline(2) ==# '{baa}'
    Expect getline(3) ==# "(doo)"
    Expect line('$') == 3
  end

  it 'line-1'
    call s:paste_code(['(foo)', '{baa}', '(doo)'])
    normal! gg
    execute 'normal' "V\<Plug>(operator-furround-delete)"
    Expect getline(1) ==# "foo"
    Expect getline(2) ==# '{baa}'
    Expect getline(3) ==# '(doo)'
    Expect line('$') == 3
  end

  it 'line-2'
    call s:paste_code(['(foo)', '{baa}', '(doo)'])
    execute 'normal' "2GV\<Plug>(operator-furround-delete)"
    Expect getline(1) ==# '(foo)'
    Expect getline(2) ==# "baa"
    Expect getline(3) ==# '(doo)'
    Expect line('$') == 3
  end

  it 'line-123'
    call s:paste_code(['(foo)', '{baa}', '(doo)'])
    execute 'normal' "ggV2j\<Plug>(operator-furround-delete)"
    Expect getline(1) ==# 'foo)'
    Expect getline(2) ==# '{baa}'
    Expect getline(3) ==# "(doo"
    Expect line('$') == 3
  end

end

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
