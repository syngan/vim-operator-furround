filetype plugin on
runtime! plugin/operator/furround.vim

let g:str = [
\	"'function(hoge)'",
\	"bb function(hoge) aa",
\	"bb function[tako](hoge) aa",
\	"bb function['tako&](hoge) aa",
\	"koko ha tako['fufu'](desu) (ka).",
\]

function! s:paste_code()
  put =g:str
  1 delete _
endfunction

describe '<Plug>(operator-furround-delete)'
  before
    new
    call s:paste_code()
  end

  after
    close!
  end

  it 'line1'
    normal! 1Gff
    execute 'normal' "\<Plug>(operator-furround-delete)f)"
	let idx = 0
    let ans = substitute(g:str[idx], "function.*(hoge)", "hoge", "")
	for i in range(len(g:str))
		if i == idx
			Expect getline(i+1) == ans
		else
			Expect getline(i+1) == g:str[i]
		endif
	endfor
  end
  it 'line2'
	let idx = 2
    normal! 2Gff
    execute 'normal' "\<Plug>(operator-furround-delete)f)"
    let ans = substitute(g:str[idx], "function.*(hoge)", "hoge", "")
	for i in range(len(g:str))
		if i == idx-1
			Expect getline(i+1) == ans
		else
			Expect getline(i+1) == g:str[i]
		endif
	endfor
  end
  it 'line3'
	let idx = 3
    normal! 3Gff
    execute 'normal' "\<Plug>(operator-furround-delete)f)"
    let ans = substitute(g:str[idx], "function.*(hoge)", "hoge", "")
	for i in range(len(g:str))
		if i == idx-1
			Expect getline(i+1) == ans
		else
			Expect getline(i+1) == g:str[i]
		endif
	endfor
  end

  it 'line4'
	let idx = 4
    normal! 4Gff
    execute 'normal' "\<Plug>(operator-furround-delete)f)"
    let ans = substitute(g:str[idx], "function.*(hoge)", "hoge", "")
	for i in range(len(g:str))
		if i == idx-1
			Expect getline(i+1) == ans
		else
			Expect getline(i+1) == g:str[i]
		endif
	endfor
  end

end

"
