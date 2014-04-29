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

Mappings:
- `<Plug>(operator-furround-append-input)`	(use input always)
- `<Plug>(operator-furround-append-reg)`	(depend on `use_input` option)
- `<Plug>(operator-furround-delete)`
- `<Plug>(operator-furround-replace)`

# Install

## NeoBundle

```vim
NeoBundleLazy 'syngan/vim-operator-furround', {
\   'depends' : [ 'kana/vim-operator-user'],
\   'autoload' : {
\	'mappings' : ['<Plug>(operator-furround-)']}
\}
```

## `<Plug>(opeartor-furround-append-input)`

- `map H <Plug>(opeartor-furround-append-input)`
- original text is `tako`
- type `Hiw` and input xxx
- note: `iw` is an `inner word`. see `:h iw`

|   input      |   result                 |   note       |
|:------------:|:------------------------:|:-------------|
| `(`          |   `(tako)`               |              |
| `[`          |   `[tako]`               |              |
| `"`          |   `"tako"`               |              |
| `hoge`       | `hoge(tako)`             | default      |
| `hoge(`      | `hoge(tako)`             |              |
| `hoge<`      | `hoge<tako>`             |              |
| `hoge["`     | `hoge["tako"]`           |              |
| `hoge()["`   | `hoge()["tako"]`         |              |
| `hoge(3, `   | `hoge(3, tako)`          |              |
| `hoge(3, "`  | `hoge(3, "tako")`        |              |
| `{\bf `      | `{\bf tako}`             | LaTeX        |
| `\begin{ho}` | `\begin{ho}tako\end{ho}` | filetype=tex |

- default block: `[]`, `()`, `{}`, `<>`, `""`, `''`

## `<Plug>(opeartor-furround-delete)`

- `map D <Plug>(opeartor-furround-delete)`

| text                 | type     | result         | note       |
|:---------------------|:---------|:---------------|:-----------|
| `hoge(tako)`         | `Df)`    | `tako`         |            |
| `hoge[tako]`         | `Df]`    | `tako`         |            |
| `tako(hoge[tako])`   | `Df)`    | `hoge[tako]`   |            |
| `{\bf foo}`          | `Da}`    | `foo`          | ft=tex     |

## vim-textobj-postexpr

- syngan/vim-textobj-postexpr
    - https://github.com/syngan/vim-textobj-postexpr

- `omap iv <Plug>(textobj-postexpr-i)`
- text is `hoge(tako(foo))` and do `Div` then `tako(foo)`

# Customize

## g:operator#furround#config


# Blog in Japanese

- [hoge() で囲みたい症候群](http://d.hatena.ne.jp/syngan/20140301/1393676442)
- [vim-operator-furround で LaTeX/XML 編集](http://d.hatena.ne.jp/syngan/20140304/1393876531)
- [vim-operator-furround の挙動を少し変えた](http://d.hatena.ne.jp/syngan/20140316/1394920671)
