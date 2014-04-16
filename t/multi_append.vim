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

describe 'multi'
  before
    new
    call s:paste_code()
	let g:operator#furround#config = {'-' : {
	\ 'merge_default_config' : 1,
	\ 'block' : [
	\ 	{'start': '\k\+(', 'end' : ')'}
	\ ]}}

  end

  after
    close!
	unlet g:operator#furround#config
  end

  it 'hoge(('
    normal! 1Gft
    let @" = 'hoge(('
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge((tako))", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

  it 'hoge(("'
    normal! 1Gft
    let @" = 'hoge(("'
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", 'hoge(("tako"))', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

  it 'hoge(["'
    normal! 1Gft
    let @" = 'hoge(["'
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", 'hoge(["tako"])', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

  it 'hoge()["'
    normal! 1Gft
    let @" = 'hoge()["'
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", 'hoge()["tako"]', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

  it 'hoge("foo")<["'
    normal! 1Gft
    let @" = 'hoge("foo")<["'
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", 'hoge("foo")<["tako"]>', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end



  it 'hoge(<)[" :: has a broken pair'
    normal! 1Gft
    let @" = 'hoge(<)["'
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", 'hoge(<)["tako"]>)', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str
    Expect getline(3) ==# g:str
  end

end
