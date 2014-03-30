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
\	"test,afo[1]"
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
	let idx = 1
    normal! 1Gff
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
  it 'line2'
	let idx = 2
    normal! 2Gff
"	Expect getpos(".")[1 : 2] == [2, 8]
    execute 'normal' "\<Plug>(operator-furround-delete)f)"
    let ans = substitute(g:str[idx-1], "function.*(hoge)", "hoge", "")
	for i in range(len(g:str))
		if i == idx-1
			Expect getline(i+1+0) == ans
		else
			Expect getline(i+1) == g:str[i]
		endif
	endfor
  end
  it 'line2 + space'
	let idx = 2
    normal! 2Gff
"	Expect getpos(".")[1 : 2] == [2, 8]
    execute 'normal' "\<Plug>(operator-furround-delete)f "
    let ans = substitute(g:str[idx-1], "function.*(hoge)", "hoge", "")
	for i in range(len(g:str))
		if i == idx-1
			Expect getline(i+1+0) == ans
		else
			Expect getline(i+1) == g:str[i]
		endif
	endfor
  end
  it 'line3'
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

  it 'line4'
	let idx = 4
    normal! 4Gff
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

  it 'line5'
	let idx = 5
    normal! 5Gff
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

  it 'line6'
	let idx = 6
    normal! 6Gff
	" NOTE: special case
    execute 'normal' "\<Plug>(operator-furround-delete)2f)"
    let ans = substitute(g:str[idx-1], "function.*(hoge)", "hoge", "")
	for i in range(len(g:str))
		if i == idx-1
			Expect getline(i+1) == ans
		else
			Expect getline(i+1) == g:str[i]
		endif
	endfor
  end

  it 'line7'
	let idx = 7
    normal! 7Gff
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

  it 'line8'
	let idx = 8
    normal! 8Gff
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

  it 'line9'
	let idx = 9
    normal! 9Gff
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

  it 'line12'
	let idx = 12
    normal! 12Gfa
    execute 'normal' "\<Plug>(operator-furround-delete)f]"
    let ans = substitute(g:str[idx-1], "afo.1.", "1", "")
	for i in range(len(g:str))
		if i == idx-1
			Expect getline(i+1) == ans
		else
			Expect getline(i+1) == g:str[i]
		endif
	endfor
  end
end

