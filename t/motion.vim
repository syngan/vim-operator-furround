filetype plugin on
runtime! plugin/operator/furround.vim

let g:str = "koko ha tako desu ka."

function! s:paste_code()
  put =[
  \    g:str,
  \    g:str,
  \    g:str,
  \    g:str,
  \    g:str,
  \ ]
  1 delete _
endfunction

describe 'motion'
  before
    new
    call s:paste_code()
  end

  after
    close!
  end

  it 'char'
    normal! 2Gft
    let @" = 'hoge('
    execute 'normal' "viw\<Plug>(operator-furround-append)"
    let ans = substitute(g:str, "tako", "hoge(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

  it 'line'
    normal! 2Gft
    let @" = 'hoge('
    execute 'normal' "V\<Plug>(operator-furround-append)"
    let ans = 'hoge(' . g:str . ')'
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

  it 'line'
    normal! 2Gft
    let @" = 'hoge('
    execute 'normal' "Vj\<Plug>(operator-furround-append)"
    Expect getline(1) ==# g:str
    Expect getline(2) ==# 'hoge(' . g:str
    Expect getline(3) ==# g:str . ')'
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end



  it 'block'
    normal! 2Gft
    let @" = 'hoge('
    execute 'normal' "\<c-v>eejj\<Plug>(operator-furround-append)"
    let ans = substitute(g:str, "tako desu", "hoge(tako desu)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# ans
    Expect getline(4) ==# ans
    Expect getline(5) ==# g:str
  end

end
