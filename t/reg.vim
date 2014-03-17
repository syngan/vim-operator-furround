filetype plugin on
runtime! plugin/operator/furround.vim

let g:str = [
\	"'function(hoge)'",
\	"bb function(hoge) aa",
\	"bb aho(function(hoge)) aa",
\	"bb function[tako](hoge) aa",
\	"bb function['tako'](hoge) aa",
\	"bb function['ta)ko'](hoge) aa",
\	"bb function['ta(ko'](hoge) aa",
\	"bb function['ta]ko'](hoge) aa",
\	"bb function['ta[ko'](hoge) aa",
\	" hoge(tako(un)) ",
\	"koko ha tako['fufu'](desu) (ka).",
\]

function! s:paste_code()
  put =g:str
  1 delete _
endfunction

describe 'register'
  before
    new
    call s:paste_code()
  end

  after
    close!
  end

  it 'delete: reg="'
	let idx = 1
    normal! 1Gff
	call setreg('"', 'koreha dummy string', 'v')
    execute 'normal' "\<Plug>(operator-furround-delete)f)"
    let ans = substitute(g:str[idx-1], "function.*(hoge)", "hoge", "")
	Expect getline(idx) == ans
	Expect getreg('"') == 'koreha dummy string'
  end

  it 'delete: reg=f'
	let idx = 2
    normal! 2Gff
"	Expect getpos(".")[1 : 2] == [2, 8]
	call setreg('f', 'koreha dummy string', 'v')
    execute 'normal' "\<Plug>(operator-furround-delete)f)"
    let ans = substitute(g:str[idx-1], "function.*(hoge)", "hoge", "")
	Expect getline(idx) == ans
	Expect getreg('f') == 'koreha dummy string'
  end

  it 'add: reg="'
	let idx = 3
    normal! 3Gff
    execute 'normal' "\<Plug>(operator-furround-delete)f)"
    let ans = substitute(g:str[idx-1], "function.*(hoge)", "hoge", "")
	for i in range(len(g:str))
		if i == idx-1
			Expect getline(i+1) == ans
		else
			Expect getline(i+1) == g:str[i]
		endif
	endfor
  end

end

