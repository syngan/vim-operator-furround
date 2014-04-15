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

describe 'input'
  before
    new
    call s:paste_code()
	set filetype=foo
  end

  after
    close!
    unlet! g:operator#furround#config
  end

  it 'default'
    normal! 2Gft
    let @" = 'hoge('
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

  it 'b=1'
    normal! 2Gft
    let @" = 'hoge('
    let g:operator#furround#config = {}
    let g:operator#furround#config['foo'] = {'use_input' : 1}
    execute 'normal' "\<Plug>(operator-furround-append)iwfoo[\<CR>"
    let ans = substitute(g:str, "tako", "foo[tako]", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

  it 'b=0'
    normal! 2Gft
    let @" = 'hoge('
    let g:operator#furround#config = {}
    let g:operator#furround#config['foo'] = {'use_input' : 0}
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

  it 'g=1'
    normal! 2Gft
    let @" = 'hoge('
    let g:operator#furround#config = {}
    let g:operator#furround#config['-'] = {'use_input' : 1}
    execute 'normal' "\<Plug>(operator-furround-append)iwfoo[\<CR>"
    let ans = substitute(g:str, "tako", "foo[tako]", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

  it 'g=0'
    normal! 2Gft
    let @" = 'hoge('
    let g:operator#furround#config = {}
    let g:operator#furround#config['-'] = {'use_input' : 0}
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

  it 'g=1,b=0'
    normal! 2Gft
    let @" = 'hoge('
    let g:operator#furround#config = {}
    let g:operator#furround#config['-'] = {'use_input' : 1}
    let g:operator#furround#config['foo'] = {'use_input' : 0}
    execute 'normal' "\<Plug>(operator-furround-append)iwiaaa\<CR>"
    let ans = substitute(g:str, "tako.*", "hogeaaa", "")
	let ans2 = "(tako) desu ka."
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# ans2
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
    Expect getline(6) ==# g:str
  end

  it 'g=1,b=1'
    normal! 2Gft
    let @" = 'hoge('
    let g:operator#furround#config = {}
    let g:operator#furround#config['-'] = {'use_input' : 1}
    let g:operator#furround#config['foo'] = {'use_input' : 1}
    execute 'normal' "\<Plug>(operator-furround-append)iwiaaa\<CR>"
    let ans = substitute(g:str, "tako", "iaaa(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

  it 'g=0,b=1'
    normal! 2Gft
    let @" = 'hoge('
    let g:operator#furround#config = {}
    let g:operator#furround#config['-'] = {'use_input' : 0}
    let g:operator#furround#config['foo'] = {'use_input' : 1}
    execute 'normal' "\<Plug>(operator-furround-append)iwiaaa\<CR>"
    let ans = substitute(g:str, "tako", "iaaa(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

end
