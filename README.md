vim-operator-furround
=====================

[![Build Status](https://travis-ci.org/syngan/vim-operator-furround.png?branch=master)](https://travis-ci.org/syngan/vim-operator-furround)

Required: 
- kana/vim-operator-user
    - https://github.com/kana/vim-operator-user

mapping:
- `<Plug>(operator-furround-append)`

## example

- `map H <Plug>(opeartor-furround-append)`
- original text is `tako`
- yank `hoge` and do `Hiw` then `hoge(tako)`
- yank `hoge[` and do `Hiw` then `hoge[tako]`
