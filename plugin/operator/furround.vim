if exists('g:loaded_operator_furround')
    finish
endif

call operator#user#define('furround-append', 'operator#furround#append')

nnoremap <Plug>(operator-furround-repeat) .

let g:loaded_operator_furround = 1
