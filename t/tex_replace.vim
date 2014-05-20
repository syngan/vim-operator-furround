filetype plugin on
runtime! plugin/operator/furround.vim

function! s:paste_code(lines)
  put =a:lines
  1 delete _
endfunction

describe '<Plug>(operator-furround-replace-input) tex-mode'

  before
    new
    set filetype=tex
    unlet! g:operator#furround#config
  end

  after
    close!
    unlet! g:operator#furround#config
  end

  it '{\bf } -> \sc{}'
    call s:paste_code(['{\bf foo}'])
    normal! 1G
    execute 'normal' "\<Plug>(operator-furround-replace-input)a{\\sc{\<CR>"
    Expect getline(1) ==# '\sc{foo}'
    Expect line('$') == 1
  end

  it '\sc{} -> {\bf }::'
    call s:paste_code(['\hoge{foo}'])
    normal! 1G
    execute 'normal' "V\<Plug>(operator-furround-delete)"
    Expect getline(1) ==# 'foo'
    Expect line('$') == 1
    call setreg('"', '{\bf ')
    execute 'normal' "V\<Plug>(operator-furround-append-reg)"
    Expect getline(1) ==# '{\bf foo}'
    Expect line('$') == 1
  end

  it '\sc{} -> {\bf }'
    call s:paste_code(['\hoge{foo}'])
    normal! 1G
    call setreg('"', '{\sf ')
    execute 'normal' "V\<Plug>(operator-furround-replace-input){\\bf \<CR>"
    Expect getline(1) ==# '{\bf foo}'
    Expect line('$') == 1
  end

  it '{\bf hoge} -> \baa{hoge}'
    call s:paste_code(['{\bf hoge}'])
    normal! 1G
    call setreg('"', '\baa{')
    execute 'normal' "\<Plug>(operator-furround-replace-reg)a{"
    Expect getline(1) ==# '\baa{hoge}'
    Expect line('$') == 1
  end

end

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
