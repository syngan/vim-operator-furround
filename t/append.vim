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

function! s:paste_motion()
  put =[
  \    g:str,
  \    g:str,
  \    g:str,
  \    g:str,
  \    g:str,
  \ ]
  1 delete _
endfunction


describe '<Plug>(operator-furround-append-reg)'
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
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
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
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
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
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
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
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "hoge<tako>", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end



  it 'hoge('
    normal! 1Gft
    let @" = 'hoge('
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "hoge(tako)", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge['
    normal! 1Gft
    let @" = 'hoge['
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "hoge[tako]", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge<'
    normal! 1Gft
    let @" = 'hoge<'
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "hoge<tako>", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge"'
    normal! 1Gft
    let @" = 'hoge"'
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", 'hoge"tako"', "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge`'
    normal! 1Gft
    let @" = 'hoge`'
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "hoge`tako`", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge(3, '
    normal! 1Gft
    let @" = 'hoge(3, '
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "hoge(3, tako)", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge(3, foo(4, '
    normal! 1Gft
    let @" = 'hoge(3, foo(4, '
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "hoge(3, foo(4, tako))", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge()'
    normal! 1Gft
    let @" = 'hoge()'
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "hoge()(tako)", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'hoge((a) + '
    normal! 1Gft
    let @" = 'hoge((a) + '
    execute 'normal' "\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "hoge((a) + tako)", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'reg'
    normal! 1Gft
    let @o = 'hage('
    execute 'normal' "\"o\<Plug>(operator-furround-append-reg)iw"
    let ans = substitute(g:str, "tako", "hage(tako)", "")
    Expect getline(1) ==# ans
    Expect getline(2) ==# g:str2
    Expect getline(3) ==# g:str3
  end

  it 'V1'
    normal! 2G
    let @" = 'hoge('
    execute 'normal' "V\<Plug>(operator-furround-append-reg)"
    Expect getline(1) ==# g:str
    Expect getline(2) ==# 'hoge(' . g:str2 . ')'
    Expect getline(3) ==# g:str3
  end

  it 'V2'
    normal! 2G
    let @" = 'hoge('
    execute 'normal' "Vj\<Plug>(operator-furround-append-reg)"
    Expect getline(1) ==# g:str
    Expect getline(2) ==# 'hoge(' . g:str2
    Expect getline(3) ==# g:str3 . ')'
    Expect getline(4) ==# g:str4
  end

end

describe 'motion-append'
  before
    new
    call s:paste_motion()
  end

  after
    close!
  end

  it 'char'
    normal! 2Gft
    let @" = 'hoge('
    execute 'normal' "viw\<Plug>(operator-furround-append-reg)"
    let ans = substitute(g:str, "tako", "hoge(tako)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

  it 'char 0-'
    normal! 2G0
    let @" = 'hoge('
    execute 'normal' "viw\<Plug>(operator-furround-append-reg)"
    let ans = substitute(g:str, "koko", "hoge(koko)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

  it 'char -$'
    normal! 2G03fk
    let @" = 'hoge('
    execute 'normal' "v$\<Plug>(operator-furround-append-reg)"
    let ans = substitute(g:str, "ka.", "hoge(ka.)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

  it 'char -$.'
    normal! 2G03fk
    let @" = 'hoge('
    execute 'normal' "vf.\<Plug>(operator-furround-append-reg)"
    let ans = substitute(g:str, "ka.", "hoge(ka.)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

  it 'char 0-$.'
    normal! 2G0
    let @" = 'hoge('
    execute 'normal' "vf.\<Plug>(operator-furround-append-reg)"
    let ans = "hoge(" . g:str . ")"
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

  it 'char 0-$.'
    normal! 2G0
    let @" = 'hoge('
    execute 'normal' "v$\<Plug>(operator-furround-append-reg)"
    let ans = "hoge(" . g:str . ")"
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# g:str
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

  it 'line'
    normal! 2Gft
    let @" = 'hoge('
    execute 'normal' "V\<Plug>(operator-furround-append-reg)"
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
    execute 'normal' "Vj\<Plug>(operator-furround-append-reg)"
    Expect getline(1) ==# g:str
    Expect getline(2) ==# 'hoge(' . g:str
    Expect getline(3) ==# g:str . ')'
    Expect getline(4) ==# g:str
    Expect getline(5) ==# g:str
  end

  it 'block-input'
    normal! 2Gft
    let @" = 'foo('
    execute 'normal' "\<c-v>eejj\<Plug>(operator-furround-append-input)hoge(\<CR>"
    let ans = substitute(g:str, "tako desu", "hoge(tako desu)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# ans
    Expect getline(4) ==# ans
    Expect getline(5) ==# g:str
  end

  it 'block-reg'
    normal! 2Gft
    let @" = 'hoge('
    execute 'normal' "\<c-v>eejj\<Plug>(operator-furround-append-reg)"
    let ans = substitute(g:str, "tako desu", "hoge(tako desu)", "")
    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# ans
    Expect getline(4) ==# ans
    Expect getline(5) ==# g:str
  end
end


describe 'block'
  before
    new
  end

  after
    close!
  end

  it 'block$'
    SKIP blockwise-operator does not work correctly
	" CountSpace() in help:g@
	1,$ delete _
  	let long_str = g:str . "foooo"
	  put =[
	  \    g:str,
	  \    g:str,
	  \    long_str,
	  \    g:str,
	  \    g:str,
	  \ ]
	1 delete _
	normal! 2Gft
	let @" = 'hoge('
    Expect line('$') == 5

	execute 'normal' "\<C-v>jj$\<Plug>(operator-furround-append-reg)"

    let ans = substitute(g:str, '\(tako.*\)$', 'hoge(\1)', '')
    let ans_2 = substitute(long_str, '\(tako.*\)$', 'hoge(\1)', '')

    Expect getline(1) ==# g:str
    Expect getline(2) ==# ans
    Expect getline(3) ==# ans_2
    Expect getline(4) ==# ans
    Expect getline(5) ==# g:str
  end
end

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
