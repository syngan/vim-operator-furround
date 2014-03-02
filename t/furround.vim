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

describe '<Plug>(operator-furround-append)'
  before
    new
    call s:paste_code()
  end

  after
    close!
  end

  it 'hoge'
    normal! 1Gft
    let @" = 'hoge'
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge(tako)", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end


  it 'hoge('
    normal! 1Gft
    let @" = 'hoge('
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge(tako)", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

  it 'hoge['
    normal! 1Gft
    let @" = 'hoge['
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge[tako]", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

  it 'hoge|'
    normal! 1Gft
    let @" = 'hoge|'
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge|tako|", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

  it 'hoge"'
    normal! 1Gft
    let @" = 'hoge"'
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", 'hoge"tako"', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end
  it 'hoge`'
    normal! 1Gft
    let @" = 'hoge`'
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge`tako`", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

  it 'reg'
    normal! 1Gft
    let @o = 'hage('
    execute 'normal' "\"o\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hage(tako)", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

end

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
