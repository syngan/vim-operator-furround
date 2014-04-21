if exists('g:loaded_operator_furround')
    finish
endif

call operator#user#define('furround-append-reg',  'operator#furround#append')
call operator#user#define('furround-append-input', 'operator#furround#appendi')
call operator#user#define('furround-delete',  'operator#furround#delete')

nnoremap <Plug>(operator-furround-repeat) .

let g:loaded_operator_furround = 1
