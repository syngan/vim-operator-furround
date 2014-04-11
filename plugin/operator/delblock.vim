if exists('g:loaded_operator_delblock')
    finish
endif

call operator#user#define('delblock-delete',  'operator#delblock#delete')

let g:loaded_operator_delblock = 1
