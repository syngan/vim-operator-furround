filetype plugin on
runtime! plugin/operator/furround.vim

let g:str = [
\    "'function(hoge)'",
\    "bb function(hoge) aa",
\    "bb aho(function(hoge)) aa",
\    "bb function[tako](hoge) aa",
\    "bb function['tako'](hoge) aa",
\    "bb function['ta)ko'](hoge) aa",
\    "bb function['ta(ko'](hoge) aa",
\    "bb function['ta]ko'](hoge) aa",
\    "bb function['ta[ko'](hoge) aa",
\    " hoge(tako(un)) ",
\    "koko ha tako['fufu'](desu) (ka).",
\]

function! s:paste_code()
  put =g:str
  1 delete _
endfunction

describe 'register'
  before
    new
    let g:__ = 'koreha dummy string __'
    let g:_f = 'koreha dummy string _f'
    call setreg('"', g:__, 'v')
    call setreg('f', g:_f, 'v')
    call s:paste_code()
  end

  after
    close!
  end

  it 'delete: reg="'
    let idx = 1
    normal! 1Gff
    execute 'normal' "\<Plug>(operator-furround-delete)f)"
    let ans = substitute(g:str[idx-1], "function.*(hoge)", "hoge", "")
    Expect getline(idx) == ans
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
  end

  it 'delete: reg=f'
    let idx = 2
    normal! 2Gff
"    Expect getpos(".")[1 : 2] == [2, 8]
    execute 'normal' "\<Plug>(operator-furround-delete)f)"
    let ans = substitute(g:str[idx-1], "function.*(hoge)", "hoge", "")
    Expect getline(idx) == ans
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
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

