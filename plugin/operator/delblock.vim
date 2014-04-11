if exists('g:loaded_operator_delblock')
    finish
endif

call operator#user#define('delblock',  'operator#delblock#do')

let g:loaded_operator_delblock = 1
