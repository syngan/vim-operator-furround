filetype plugin on
runtime! plugin/operator/furround.vim

let g:str = "koko ha tako desu ka."

function! s:paste_code()
  put =[
  \    g:str,
  \    g:str,
  \    g:str,
  \ ]
  1 delete _
endfunction

describe '<Plug>(operator-furround-append) tex-mode'

  before
    new
    call s:paste_code()
  end

  after
    close!
  end

  it 'begin-default'
    normal! 1Gft
    let @" = "\\begin{center}"
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '\\begin{center}tako\\end{center}', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

  it 'begin-defualt b:=0'
    normal! 1Gft
    let @" = "\\begin{center}"
    let b:operator_furround_latex = 0
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '\\begin{center}(tako)', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

  it 'begin-defualt b:=1'
    normal! 1Gft
    let @" = "\\begin{center}"
    let b:operator_furround_latex = 1
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '\\begin{center}tako\\end{center}', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

  it 'begin-defualt g:=1'
    normal! 1Gft
    let @" = "\\begin{center}"
    let g:operator_furround_latex = 1
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '\\begin{center}tako\\end{center}', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

  it 'begin-defualt g:=0'
    normal! 1Gft
    let @" = "\\begin{center}"
    let g:operator_furround_latex = 0
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '\\begin{center}(tako)', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

  it 'begin-defualt b:&g:'
    normal! 1Gft
    let @" = "\\begin{center}"
    let g:operator_furround_latex = 1
    let b:operator_furround_latex = 1
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '\\begin{center}tako\\end{center}', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

  it 'begin-defualt !b:&g:'
    normal! 1Gft
    let @" = "\\begin{center}"
    let g:operator_furround_latex = 1
    let b:operator_furround_latex = 0
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '\\begin{center}(tako)', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

  it 'begin-defualt b:=1&g:=0'
    normal! 1Gft
    let @" = "\\begin{center}"
    let g:operator_furround_latex = 0
    let b:operator_furround_latex = 1
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '\\begin{center}tako\\end{center}', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

  it 'begin/begin'
    normal! 1Gft
    let @" = "\\begin{center}\\begin{foo}"
    let b:operator_furround_latex = 1
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '\\begin{center}\\begin{foo}tako\\end{foo}\\end{center}', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end


  it 'begin/begin/end/begin'
    normal! 1Gft
    let @" = "\\begin{center}\\begin{foo}\\end{foo}\\begin{goo}"
    let b:operator_furround_latex = 1
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", '\\begin{center}\\begin{foo}\\end{foo}\\begin{goo}tako\\end{goo}\\end{center}', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

end


" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
