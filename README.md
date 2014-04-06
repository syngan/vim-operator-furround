vim-operator-furround
=====================

[![Build Status](https://travis-ci.org/syngan/vim-operator-furround.svg?branch=master)](https://travis-ci.org/syngan/vim-operator-furround)

This plugin is a Vim operator to surround a text by register content.

Required:
- [kana/vim-operator-user](https://github.com/kana/vim-operator-user)

Recommended:
- [tpope/vim-repeat](https://github.com/tpope/vim-repeat)

Related:
- [rhysd/vim-operator-surround](https://github.com/rhysd/vim-operator-surround)
- [tpope/vim-surround](https://github.com/tpope/vim-surround)

mappings:
- `<Plug>(operator-furround-append)`	(depend on `[bg]:operator_furround_use_input`)
- `<Plug>(operator-furround-appendi)`	(use input always)
- `<Plug>(operator-furround-delete)`

# Install

## NeoBundle

```vim
NeoBundleLazy 'syngan/vim-operator-furround', {
\   'depends' : [ 'kana/vim-operator-user'],
\   'autoload' : {
\	'mappings' : ['<Plug>(operator-furround-appendi)',
\                 '<Plug>(operator-furround-append)',
\                 '<Plug>(operator-furround-delete)']},
\}
```

## `<Plug>(opeartor-furround-append)`

- `map H <Plug>(opeartor-furround-append)`
- original text is `tako`
- yank `hoge` and do `Hiw` then `hoge(tako)`
- yank `hoge[` and do `Hiw` then `hoge[tako]`
- yank `hoge<` and do `Hiw` then `hoge<tako>`
- yank `hoge|` and do `Hiw` then `hoge|tako|`
- yank `hoge"` and do `Hiw` then `hoge"tako"`

- yank `hoge["` and do `Hiw` then `hoge["tako"]`
- yank `hoge(["` and do `Hiw` then `hoge(["tako"])`
- yank `hoge()["` and do `Hiw` then `hoge()["tako"]`
- yank `hoge(3, ` and do `Hiw` then `hoge(3, tako)`
- yank `hoge(3, "` and do `Hiw` then `hoge(3, "tako")`
- yank `{\bf ` and do `Hiw` then `{\bf tako}`

- pair: `[]`, `()`, `{}`, `<>`, `||`, `""`, `''`

## `<Plug>(opeartor-furround-delete)`

- `map D <Plug>(opeartor-furround-delete)`
- text is `hoge(tako)` and do `Df)` then `tako`
- text is `hoge[tako]` and do `Df]` then `tako`
- text is `hoge(tako(foo))` and do `Df)` then `foo)`
- text is `hoge(tako(foo))` and do `D2f)` then `tako(foo)`

## vim-textobj-postexpr

- syngan/vim-textobj-postexpr
    - https://github.com/syngan/vim-textobj-postexpr

- `omap iv <Plug>(textobj-postexpr-i)`
- text is `hoge(tako(foo))` and do `Div` then `tako(foo)`

# Customize

## [bg]:operator_furround_latex

- default `1`
- original text is `tako`
- yank `\begin{center}` and do `Hiw` then `\begin{center}tako\end{center}`

## [bg]:operator_furround_xml

- default `0`
- original text is `tako`
- yank `<p>` and do `Hiw` then `<p>tako</p>`
- yank `<p><q>` and do `Hiw` then `<p><q>tako</q></p>`

## [bg]:operator_furround_use_input

- default `0`
- original text is `tako`
- do `Hiw` and type `hoge(` then `hoge(tako)`
- do `Hiw` and type `<CR>` (an empty string) then use register `"`
- do `"fHiw` then use register `f`

# Blog in Japanese

- [hoge() で囲みたい症候群](http://d.hatena.ne.jp/syngan/20140301/1393676442)
- [vim-operator-furround で LaTeX/XML 編集](http://d.hatena.ne.jp/syngan/20140304/1393876531)
- [vim-operator-furround の挙動を少し変えた](http://d.hatena.ne.jp/syngan/20140316/1394920671)
