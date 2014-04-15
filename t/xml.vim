filetype plugin on
runtime! plugin/operator/furround.vim

let g:str = [
     \ 'filetype plugin on',
     \ 'runtime! plugin/operator/furround.vim',
     \ "koko ha tako desu ka.",
     \ 'printf("hoge\n", (sqrt(value[1,2][3]) + 1) + func[1,2](a, b, c));',
     \ ]

function! s:paste_code()
  for i in range(len(g:str))
    call setline(i+1, g:str[i])
  endfor
endfunction

describe '<Plug>(operator-furround-append) xml-mode'

  before
    new
    call s:paste_code()
    unlet! g#operator#furround#config
    set filetype=foo
  end

  after
    close!
  end

  it 'begin-default'
    normal! 3Gft
    let @" = "<p>"
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str[2], "tako", '<p>(tako)', "")
    Expect getline(1) ==# g:str[0]
    Expect getline(2) ==# g:str[1]
    Expect getline(3) ==# ans
    Expect getline(4) ==# g:str[3]
  end

  it 'begin-default g=0'
    normal! 3Gft
    let @" = "<p>"
    let g:operator#furround#config = {}
    let g:operator#furround#config['-'] = {'xml' : 0}
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str[2], "tako", '<p>(tako)', "")
    Expect getline(1) ==# g:str[0]
    Expect getline(2) ==# g:str[1]
    Expect getline(3) ==# ans
    Expect getline(4) ==# g:str[3]
  end

  it 'begin-default g=1'
    normal! 3Gft
    let @" = "<p>"
    let g:operator#furround#config = {}
    let g:operator#furround#config['-'] = {'xml' : 1}
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str[2], "tako", '<p>tako</p>', "")
    Expect getline(1) ==# g:str[0]
    Expect getline(2) ==# g:str[1]
    Expect getline(3) ==# ans
    Expect getline(4) ==# g:str[3]
  end

  it 'begin-default b=0'
    normal! 3Gft
    let @" = "<p>"
    let g:operator#furround#config = {}
    let g:operator#furround#config['foo'] = {'xml' : 0}
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str[2], "tako", '<p>(tako)', "")
    Expect getline(1) ==# g:str[0]
    Expect getline(2) ==# g:str[1]
    Expect getline(3) ==# ans
    Expect getline(4) ==# g:str[3]
  end

  it 'begin-default b=1'
    normal! 3Gft
    let @" = "<p>"
    let g:operator#furround#config = {}
    let g:operator#furround#config['foo'] = {'xml' : 1}
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str[2], "tako", '<p>tako</p>', "")
    Expect getline(1) ==# g:str[0]
    Expect getline(2) ==# g:str[1]
    Expect getline(3) ==# ans
    Expect getline(4) ==# g:str[3]
  end

  it 'begin-default b=0,g=0'
    normal! 3Gft
    let @" = "<p>"
    let g:operator#furround#config = {}
    let g:operator#furround#config['-'] = {'xml' : 0}
    let g:operator#furround#config['foo'] = {'xml' : 0}
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str[2], "tako", '<p>(tako)', "")
    Expect getline(1) ==# g:str[0]
    Expect getline(2) ==# g:str[1]
    Expect getline(3) ==# ans
    Expect getline(4) ==# g:str[3]
  end

  it 'begin-default b=0,g=1'
    normal! 3Gft
    let @" = "<p>"
    let g:operator#furround#config = {}
    let g:operator#furround#config['-'] = {'xml' : 1}
    let g:operator#furround#config['foo'] = {'xml' : 0}
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str[2], "tako", '<p>(tako)', "")
    Expect getline(1) ==# g:str[0]
    Expect getline(2) ==# g:str[1]
    Expect getline(3) ==# ans
    Expect getline(4) ==# g:str[3]
  end

  it 'begin-default b=1,g=0'
    normal! 3Gft
    let @" = "<p>"
    let g:operator#furround#config = {}
    let g:operator#furround#config['-'] = {'xml' : 0}
    let g:operator#furround#config['foo'] = {'xml' : 1}
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str[2], "tako", '<p>tako</p>', "")
    Expect getline(1) ==# g:str[0]
    Expect getline(2) ==# g:str[1]
    Expect getline(3) ==# ans
    Expect getline(4) ==# g:str[3]
  end

  it 'begin-default b=1,g=1'
    normal! 3Gft
    let @" = "<p>"
    let g:operator#furround#config = {}
    let g:operator#furround#config['-'] = {'xml' : 1}
    let g:operator#furround#config['foo'] = {'xml' : 1}
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str[2], "tako", '<p>tako</p>', "")
    Expect getline(1) ==# g:str[0]
    Expect getline(2) ==# g:str[1]
    Expect getline(3) ==# ans
    Expect getline(4) ==# g:str[3]
  end

  it 'many'
    normal! 3Gft
    let str = "<hoge u=1><foo/><taa v=2/><r><p w=3></p></r><q x=5 y=3>"
    let @" = str
    let g:operator#furround#config = {}
    let g:operator#furround#config['-'] = {'xml' : 1}
    let g:operator#furround#config['foo'] = {'xml' : 1}
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str[2], "tako", str . 'tako</q></taa></hoge>', "")
    Expect getline(1) ==# g:str[0]
    Expect getline(2) ==# g:str[1]
    Expect getline(3) ==# ans
    Expect getline(4) ==# g:str[3]
  end

  it 'real'
    let str = '<font color="#ffffff"><span style="background-color:black; color:white;">'
    let @" = str

    let g:operator#furround#config = {}
    let g:operator#furround#config['-'] = {'xml' : 1}
    let g:operator#furround#config['foo'] = {'xml' : 1}
    normal! 4Gfg
    execute 'normal' "vl\<Plug>(operator-furround-append)"
    let ans = substitute(g:str[3], "ge", str . 'ge</span></font>', "")
    Expect getline(1) ==# g:str[0]
    Expect getline(2) ==# g:str[1]
    Expect getline(3) ==# g:str[2]
    Expect getline(4) ==# ans
  end
end

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
