filetype plugin on
runtime! plugin/operator/furround.vim

scriptencoding utf-8

function! s:paste_code(lines)
  put =a:lines
  1 delete _
endfunction

describe 'replace'
  before
    new
    execute "setlocal filetype=foo"
  end

  after
    close!
  end

  it '(tako) -> [tako]'
    call s:paste_code(['(tako)'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-furround-replace-input)a([\<CR>"
    Expect getline(1) == '[tako]'
    Expect line('$') == 1
  end

  it '(tako) -> {''tako''}'
    call s:paste_code(['(tako)'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-furround-replace-input)a({'\<CR>"
    Expect getline(1) == '{''tako''}'
    Expect line('$') == 1
  end

  it '("tako") -> <{"tako"}>'
    call s:paste_code(['("tako")'])
    normal! gg0
    execute 'normal' "\<Plug>(operator-furround-replace-input)a(<{\<CR>"
    Expect getline(1) == '<{"tako"}>'
    Expect line('$') == 1
  end

end
