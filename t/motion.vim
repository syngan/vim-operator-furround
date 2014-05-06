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

describe 'motion-append'
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
