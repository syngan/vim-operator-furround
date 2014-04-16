filetype plugin on
runtime! plugin/operator/furround.vim

let g:str = "koko ha tako desu ka."
let g:str2 = g:str . '2'
let g:str3 = g:str . '3'
let g:str4 = g:str . '4'

function! s:paste_code()
  put =[
  \    g:str,
  \    g:str2,
  \    g:str3,
  \    g:str4,
  \ ]
  1 delete _
endfunction

describe '<Plug>(operator-furround-append) tex-mode'

  before
    new
    set filetype=tex
    unlet! g:operator#furround#config
    call s:paste_code()
  end

  after
    close!
    unlet! g:operator#furround#config
  end

  it 'begin-default'
    normal! 1Gft
    let @" = "\\begin{center}"
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '\\begin{center}tako\\end{center}', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'begin/begin'
    normal! 1Gft
    let @" = "\\begin{center}\\begin{foo}"
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '\\begin{center}\\begin{foo}tako\\end{foo}\\end{center}', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'begin/begin/end/begin'
    normal! 1Gft
    let @" = "\\begin{center}\\begin{foo}\\end{foo}\\begin{goo}"
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '\\begin{center}\\begin{foo}\\end{foo}\\begin{goo}tako\\end{goo}\\end{center}', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it '{\bf '
    call setreg('"', '{\bf ', 'v')
    normal! 1Gft
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '{\\bf tako}', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it '\( '
    call setreg('"', '\(', 'v')
    normal! 1Gft
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '\\(tako\\)', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it '\[ '
    call setreg('"', '\[ ', 'v')
    normal! 1Gft
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '\\[ tako\\]', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it '$'
    call setreg('"', '$', 'v')
    normal! 1Gft
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '$tako$', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it '$$'
    call setreg('"', '$$', 'v')
    normal! 1Gft
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '$$tako$$', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'begin/end V'
    call setreg('"', '\begin{center}', 'V')
    normal! 2G
    execute 'normal' "V\<Plug>(operator-furround-append)"
    Expect getline(1) ==# g:str
    Expect getline(2) ==# '\begin{center}'
    Expect getline(3) ==# g:str2
    Expect getline(4) ==# '\end{center}'
    Expect getline(5) ==# g:str3
  end

  it 'begin/end V2'
    call setreg('"', '\begin{center}', 'V')
    normal! 2G
    execute 'normal' "Vj\<Plug>(operator-furround-append)"
    Expect getline(1) ==# g:str
    Expect getline(2) ==# '\begin{center}'
    Expect getline(3) ==# g:str2
    Expect getline(4) ==# g:str3
    Expect getline(5) ==# '\end{center}'
    Expect getline(6) ==# g:str4
  end

end


" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
