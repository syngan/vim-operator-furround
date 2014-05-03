filetype plugin on
runtime! plugin/operator/*.vim

scriptencoding utf-8

function! s:paste_code(lines)
  put =a:lines
  1 delete _
endfunction

describe 'tex-pair'
  before
    new
    set filetype=tex
  end

  after
    close!
  end

  it '{\bf tako}'
    call s:paste_code(['{\bf tako}'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-furround-delete)f}"
    Expect getline(1) == 'tako'
  end

  it '\verb|tako|'
    call s:paste_code(['\verb|tako|'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-furround-delete)2f|"
    Expect getline(1) == 'tako'
  end

  it '\verbmtakom'
    call s:paste_code(['\verbmtakom'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-furround-delete)2fm"
    Expect getline(1) == 'tako'
  end

  it '\verb*|tako|'
    call s:paste_code(['\verb*|tako|'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-furround-delete)2f|"
    Expect getline(1) == 'tako'
  end

  it '\verb*mtakom'
    call s:paste_code(['\verb*mtakom'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-furround-delete)2fm"
    Expect getline(1) == 'tako'
  end
  it '\cite{tako}'
    call s:paste_code(['\cite{tako}'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-furround-delete)f}"
    Expect getline(1) == 'tako'
  end

  it '\includegraphics[width=60mm]{tako}'
    call s:paste_code(['\includegraphics[width=60mm]{tako}'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-furround-delete)f}"
    Expect getline(1) == 'tako'
  end

  it '\begin{center}tako\end{center}'
    call s:paste_code(['\begin{center}tako\end{center}'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-furround-delete)2f}"
    Expect getline(1) == 'tako'
  end

  it '\begin{figure}[htbp]'
    call s:paste_code(['\begin{figure}[htbp]', 'tako', '\end{figure}'])
    normal! gg0
    execute 'normal' "V2j\<Plug>(operator-furround-delete)"
    Expect getline(1) == 'tako'
    Expect line('$') == 1
  end

  it '\begin{figure*}1'
    call s:paste_code([
    \ '\begin{figure*}[tb] % {{{',
    \ 'hoge',
    \ '\end{figure*}'])  " }}}

    normal! gg0
    execute 'normal' "V2j\<Plug>(operator-furround-delete)"
    Expect getline(1) == '% {{{'
    " }}}
    Expect getline(2) == 'hoge'
    Expect line('$') == 2
  end

  it '\begin{figure*}'
    call s:paste_code([
    \ '\begin{figure*}[tb] % {{{',
    \ 'hoge',
    \ '\end{figure*} %}}}'])

    normal! gg0
    execute 'normal' "V2j\<Plug>(operator-furround-delete)"
    Expect getline(1) == 'hoge'
    Expect line('$') == 1
  end

end


" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
