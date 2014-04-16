filetype plugin on
runtime! plugin/operator/furround.vim

let g:str = "koko ha tako desu ka."
let g:str2 = "koreha line 2"
let g:str3 = "hoge de kakomitai syo-ko-gun"
let g:str4 = "tuika sita"

function! s:paste_code()
  put =[
  \    g:str,
  \    g:str2,
  \    g:str3,
  \    g:str4,
  \ ]
  1 delete _
endfunction

describe '<Plug>(operator-furround-append)'
  before
    new
    set filetype=foo
    call s:paste_code()
    unlet! g:operator#furround#config
  end

  after
    close!
    unlet! g:operator#furround#config
  end

  it 'hoge'
    normal! 1Gft
    let @" = 'hoge'
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge(tako)", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge g:'
    normal! 1Gft
    let @" = 'hoge'
    let g:operator#furround#config = {}
    let g:operator#furround#config['-'] = {'default_append_block': ['<', '>']}
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge<tako>", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge b:'
    normal! 1Gft
    let @" = 'hoge'
    let g:operator#furround#config = {}
    let g:operator#furround#config['foo'] = {'default_append_block': ['<', '>']}
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge<tako>", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge b: && g:'
    normal! 1Gft
    let @" = 'hoge'
    let g:operator#furround#config = {}
    let g:operator#furround#config['-'] = {'default_append_block': ['[', ']']}
    let g:operator#furround#config['foo'] = {'default_append_block': ['<', '>']}
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge<tako>", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end



  it 'hoge('
    normal! 1Gft
    let @" = 'hoge('
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge(tako)", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge['
    normal! 1Gft
    let @" = 'hoge['
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge[tako]", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge<'
    normal! 1Gft
    let @" = 'hoge<'
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge<tako>", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge"'
    normal! 1Gft
    let @" = 'hoge"'
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", 'hoge"tako"', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge`'
    normal! 1Gft
    let @" = 'hoge`'
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge`tako`", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge(3, '
    normal! 1Gft
    let @" = 'hoge(3, '
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge(3, tako)", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge(3, foo(4, '
    normal! 1Gft
    let @" = 'hoge(3, foo(4, '
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge(3, foo(4, tako))", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge()'
    normal! 1Gft
    let @" = 'hoge()'
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge()(tako)", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge((a) + '
    normal! 1Gft
    let @" = 'hoge((a) + '
    execute 'normal' "\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hoge((a) + tako)", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'reg'
    normal! 1Gft
    let @o = 'hage('
    execute 'normal' "\"o\<Plug>(operator-furround-append)iw"
    let ans = substitute(g:str, "tako", "hage(tako)", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'V1'
    normal! 2G
    let @" = 'hoge('
    execute 'normal' "V\<Plug>(operator-furround-append)"
    Expect getline(1) ==# g:str
    Expect getline(2) ==# 'hoge(' . g:str2 . ')'
    Expect getline(3) ==# g:str3
  end

  it 'V2'
    normal! 2G
    let @" = 'hoge('
    execute 'normal' "Vj\<Plug>(operator-furround-append)"
    Expect getline(1) ==# g:str
    Expect getline(2) ==# 'hoge(' . g:str2
    Expect getline(3) ==# g:str3 . ')'
    Expect getline(4) ==# g:str4
  end

end

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
