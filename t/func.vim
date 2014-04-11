filetype plugin on
runtime! plugin/operator/*.vim

scriptencoding utf-8

map <silent>sd <Plug>(operator-delblock)
let g:__ = 'koreha dummy string __'
let g:_f = 'koreha dummy string _f'

let g:operator#delblock#config = {
\ '-' : {
\   'merge_default_config' : 1,
\   'block' : [
\     {'start': '\k\+(', 'end': ')'},
\     {'start': '\k\+\[', 'end': '\]'},
\   ]},
\}



function! s:paste_code(lines)
  put =a:lines
  1 delete _
endfunction


describe 'del-char'
  before
    new
    let g:__ = 'koreha dummy string __'
    let g:_f = 'koreha dummy string _f'
    call setreg('"', g:__, 'v')
    call setreg('f', g:_f, 'v')
  end

  after
    close!
  end

  it '1line'
    call s:paste_code(['hoge(tako)'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-delblock)f)"
    Expect getline(1) == 'tako'
    Expect line('$') == 1
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
  end

  it 'gomi + 1line'
    call s:paste_code(['aa hoge(tako)'])
    normal! gg0fh
    execute 'normal' "\<Plug>(operator-delblock)f)"
    Expect getline(1) == 'aa tako'
    Expect line('$') == 1
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
  end

  it '1line+gomi'
    call s:paste_code(['hoge(tako)aa'])
    normal! gg0fh
    execute 'normal' "\<Plug>(operator-delblock)f)"
    Expect getline(1) == 'takoaa'
    Expect line('$') == 1
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
  end

  it '1line + gomi'
    call s:paste_code(['hoge(tako) aa'])
    normal! gg0fh
    execute 'normal' "\<Plug>(operator-delblock)f)"
    Expect getline(1) == 'tako aa'
    Expect line('$') == 1
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
  end

  it '"1line"'
    call s:paste_code(['"hoge(tako)"'])
    normal! gg0fh
    execute 'normal' "\<Plug>(operator-delblock)f)"
    Expect getline(1) == '"tako"'
    Expect line('$') == 1
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
  end

  it '2line'
    call s:paste_code(['hoge(tako,', 'vim)'])
    normal! gg0
    execute 'normal' "v/)\<CR>\<Plug>(operator-delblock)"
    Expect getline(1) == 'tako,'
    Expect getline(2) == 'vim'
    Expect line('$') == 2
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
  end

  it '[_]2line'
    call s:paste_code([' hoge(tako,', 'vim)'])
    normal! gg0l
    execute 'normal' "v/)\<CR>\<Plug>(operator-delblock)"
    Expect getline(1) == ' tako,'
    Expect getline(2) == 'vim'
    Expect line('$') == 2
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
  end
end


describe 'del-line'
  before
    new
  end

  after
    close!
  end

  it '1line'
    call s:paste_code(['hoge(tako)'])
    normal! gg0
    execute 'normal' "V\<Plug>(operator-delblock)"
    Expect getline(1) == 'tako'
    Expect line('$') == 1
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
  end

  it 'gomi + 1line'
    call s:paste_code(['aa', 'hoge(tako)'])
    normal! 2G0
    execute 'normal' "V\<Plug>(operator-delblock)"
    Expect getline(1) == 'aa'
    Expect getline(2) == 'tako'
    Expect line('$') == 2
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
  end

  it '1line + gomi'
    call s:paste_code(['hoge(tako)', 'aa'])
    normal! gg0
    execute 'normal' "V\<Plug>(operator-delblock)"
    Expect getline(1) == 'tako'
    Expect getline(2) == 'aa'
    Expect line('$') == 2
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
  end

  it 'gomi + 1line + gomi'
    call s:paste_code(['aa', 'hoge(tako)', 'bb'])
    normal! 2G0
    execute 'normal' "V\<Plug>(operator-delblock)"
    Expect getline(1) == 'aa'
    Expect getline(2) == 'tako'
    Expect getline(3) == 'bb'
    Expect line('$') == 3
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
  end

  it '2line'
    call s:paste_code(['hoge(tako,', 'vim)'])
    normal! gg0
    execute 'normal' "Vj\<Plug>(operator-delblock)"
    Expect getline(1) == 'tako,'
    Expect getline(2) == 'vim'
    Expect line('$') == 2
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
  end

  it '[_]2line'
    " 仕様としては, '(' まで削除なので空白も削除する
    call s:paste_code([' hoge(tako,', 'vim)'])
    normal! gg0
    execute 'normal' "Vj\<Plug>(operator-delblock)"
    Expect getline(1) == 'tako,'
    Expect getline(2) == 'vim'
    Expect line('$') == 2
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
  end

  it 'gomi + 2line'
    call s:paste_code(['aa', 'hoge(tako,', 'vim)'])
    normal! 2G0
    execute 'normal' "Vj\<Plug>(operator-delblock)"
    Expect getline(1) == 'aa'
    Expect getline(2) == 'tako,'
    Expect getline(3) == 'vim'
    Expect line('$') == 3
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
  end

  it '2line + gomi'
    call s:paste_code(['hoge(tako,', 'vim)', 'bb'])
    normal! gg0
    execute 'normal' "Vj\<Plug>(operator-delblock)"
    Expect getline(1) == 'tako,'
    Expect getline(2) == 'vim'
    Expect getline(3) == 'bb'
    Expect line('$') == 3
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
  end

  it 'gomi + 2line + gomi'
    call s:paste_code(['aa', 'hoge(tako,', 'vim)', 'bb'])
    normal! 2G0
    execute 'normal' "Vj\<Plug>(operator-delblock)"
    Expect getline(1) == 'aa'
    Expect getline(2) == 'tako,'
    Expect getline(3) == 'vim'
    Expect getline(4) == 'bb'
    Expect line('$') == 4
    Expect getreg('"') == g:__
    Expect getreg('f') == g:_f
  end
end


" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
