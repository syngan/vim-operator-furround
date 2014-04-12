filetype plugin on
runtime! plugin/operator/*.vim

scriptencoding utf-8

function! s:paste_code(lines)
  put =a:lines
  1 delete _
endfunction

for g:fp in ['', 'tex', 'c', 'vim']
  describe 'del-pair'
    before
      new
      execute "setlocal filetype=" . g:fp
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
endfor

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
