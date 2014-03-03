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
- yank `hoge<` and do `Hiw` then `hoge<tako>`
- yank `hoge|` and do `Hiw` then `hoge|tako|`
- yank `hoge"` and do `Hiw` then `hoge"tako"`

- pair: `[]`, `()`, `{}`, `<>`, `||`, `""`, `''`

### [bg]:operator_furround_latex

- default 1
- original text is `tako`
- yank `\begin{center}` and do `Hiw` then `\begin{center}tako\end{center}`

### [bg]:operator_furround_xml

- default 0
- original text is `tako`
- yank `<p>` and do `Hiw` then `<p>tako</p>`
- yank `<p><q>` and do `Hiw` then `<p><q>tako</q></p>`

## blog

- [hoge() で囲みたい症候群](http://d.hatena.ne.jp/syngan/20140301/1393676442)
- [vim-operator-furround で LaTeX/XML 編集](http://d.hatena.ne.jp/syngan/20140304/1393876531)
