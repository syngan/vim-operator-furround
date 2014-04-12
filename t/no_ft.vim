filetype plugin on
runtime! plugin/operator/*.vim

scriptencoding utf-8

map <silent>sd <Plug>(operator-delblock)
let g:__ = 'koreha dummy string __'
let g:_f = 'koreha dummy string _f'

function! s:paste_code(lines)
  put =a:lines
  1 delete _
endfunction


describe 'del-pair'
  before
    new
    set filetype=
  end

  after
    close!
  end

  it '(tako)'
    call s:paste_code(['(tako)'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-delblock)f)"
    Expect getline(1) == 'tako'
  end

  it '{tako}'
    call s:paste_code(['{tako}'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-delblock)f}"
    Expect getline(1) == 'tako'
  end

  it '[tako]'
    call s:paste_code(['[tako]'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-delblock)f]"
    Expect getline(1) == 'tako'
  end

  it '"tako"'
    call s:paste_code(['"tako"'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-delblock)f\""
    Expect getline(1) == 'tako'
  end

  it '<tako>'
    call s:paste_code(['<tako>'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-delblock)f>"
    Expect getline(1) == 'tako'
  end

  it '''tako'''
    call s:paste_code(['''tako'''])
    normal! gg0
    execute 'normal' "\<Plug>(operator-delblock)f'"
    Expect getline(1) == 'tako'
  end

end


" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
