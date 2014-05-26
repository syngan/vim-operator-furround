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

let s:conf = [
\     {'start': '\k\+(', 'end': ')', 'regexp': 1},
\     {'start': '\k\+\[', 'end': ']', 'regexp': 1},
\     {'start': '(', 'end': ')', 'regexp': 0},
\     {'start': '[', 'end': ']', 'regexp': 0},
\ ]

describe 'input'
  before
    new
    call s:paste_code()
	set filetype=foo

    unlet! g:operator#furround#config
    let g:operator#furround#config = {}
	let g:operator#furround#config['-'] = {'block': s:conf}
	let g:operator#furround#config['foo'] = {'block': s:conf}
  end

  after
    close!
    unlet! g:operator#furround#config
  end

  it 'default'
    normal! 2Gft
    let @" = 'hoge('

    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
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
    let g:operator#furround#config['foo']['use_input'] = 1
    execute 'normal' "\<Plug>(operator-furround-append-reg)iwfoo[\<CR>"
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
    let g:operator#furround#config['foo']['use_input'] = 0
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "hoge(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

  it 'g=1'
	" b の指定があるので, デフォルトで動作する
    normal! 2Gft
    let @" = 'hoge('
    let g:operator#furround#config['-']['use_input'] =  1
    execute 'normal' "\<Plug>(operator-furround-append-reg)iww<CR>"
    let ans = substitute(g:str, "tako", "hoge(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

  it 'g=0'
    normal! 2Gft
    let @" = 'hoge('
    let g:operator#furround#config['-']['use_input'] =  0
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
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
    let g:operator#furround#config['-']['use_input'] =  1
    let g:operator#furround#config['foo']['use_input'] = 0
    execute 'normal' "\<Plug>(operator-furround-append-reg)iwiaaa\<CR>"
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
    let g:operator#furround#config['-']['use_input'] =  1
    let g:operator#furround#config['foo']['use_input'] = 1
    execute 'normal' "\<Plug>(operator-furround-append-reg)iwiaaa\<CR>"
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
    let g:operator#furround#config['-']['use_input'] =  0
    let g:operator#furround#config['foo']['use_input'] = 1
    execute 'normal' "\<Plug>(operator-furround-append-reg)iwiaaa\<CR>"
    let ans = substitute(g:str, "tako", "iaaa(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

end


describe 'key'
  before
    new
    call s:paste_code()

    unlet! g:operator#furround#config
    let g:operator#furround#config = {}
	let g:operator#furround#config['-'] = {'key': {
	\    'c' : ['hoge(', ')'],
	\    'e' : ['goo<', '>'],
	\ }}
	let g:operator#furround#config['-']['block'] = s:conf
	let g:operator#furround#config['foo'] = {'key': {
	\    'c': ['HOGE(', ')'], 
	\    'd': ['PAA[', ']'],
	\ }}
	let g:operator#furround#config['foo']['block'] = s:conf
	" defined but dont have 'key'
	let g:operator#furround#config['baa'] = {}
	let g:operator#furround#config['baa']['block'] = s:conf
  end

  after
    close!
    unlet! g:operator#furround#config
  end

  it 'foo: c('
    normal! 2Gft
	set filetype=foo
	call setreg('"', 'c(')
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "c(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
  end

  it 'foo: c'
    normal! 2Gft
	set filetype=foo
	call setreg('"', 'c')
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "HOGE(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
  end

  it 'foo: c: merge=1'
    normal! 2Gft
	set filetype=foo
	let g:operator#furround#config['foo']['merge_default_config_user'] = 1
	call setreg('"', 'c')
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "HOGE(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
  end

  it 'foo: d'
    normal! 2Gft
	set filetype=foo
	call setreg('"', 'd')
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "PAA[tako]", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
  end

  it 'foo: e: merge=0'
    normal! 2Gft
	set filetype=foo
	call setreg('"', 'e')
	let g:operator#furround#config['foo']['merge_default_config_user'] = 0
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "e(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
  end

  it 'foo: e: merge=1'
    normal! 2Gft
	set filetype=foo
	let g:operator#furround#config['foo']['merge_default_config_user'] = 1
	call setreg('"', 'e')
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "goo<tako>", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
  end

  " undefined 'key'
  it 'baa: c'
    normal! 2Gft
	set filetype=baa
	let g:operator#furround#config['baa']['merge_default_config_user'] = 0
	call setreg('"', 'c')
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "c(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
  end

  it 'baa: c: merge=1'
    normal! 2Gft
	set filetype=baa
	let g:operator#furround#config['baa']['merge_default_config_user'] = 1
	call setreg('"', 'c')
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "hoge(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
  end

  it 'baa: d'
    normal! 2Gft
	set filetype=baa
	call setreg('"', 'd')
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "d(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
  end

  " undefined 'filetype'
  it 'syngan: c'
    normal! 2Gft
	set filetype=syngan
	call setreg('"', 'c')
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "hoge(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
  end

  it 'syngan: d'
    normal! 2Gft
	set filetype=syngan
	call setreg('"', 'd')
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "d(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
  end

end


