# Cheatsheet

Leader is `,`. Press `q` or `<Esc>` to close.

## General
  `jj`              Escape insert mode
  `,,`              Show this cheatsheet
  `,q`              Close current split

## Splits & tabs
  `,v` / `,s`       New vertical / horizontal split
  `,tn`             New tab
  `,t1`..`,t9`      Switch to tab 1..9
  `,t0`             Switch to last tab
  `,m{w,a,s,d}`     Window navigation (up / left / down / right)

## Buffers (bufferline)
  `,1`..`,9`        Switch to visible buffer 1..9 (renumbers as buffers close)
  `,0`              Switch to visible buffer 10

## Config
  `,cv` / `,cs`     Open vimrc in vertical / horizontal split
  `,ct`             Open vimrc in new tab
  `,c.`             Open vimrc in current buffer
  `,cr`             Reload vimrc

## Files & search (telescope)
  `,ff`             Find files
  `,fg`             Find git files
  `,fl`             Live grep (with ripgrep flags)
  `,fe`             Live grep open buffers
  `,fs`             Search buffers
  `,fw`             Search projects
  `,fv`             Search terminals

  Inside a picker:
    `C-t`           Open in new tab
    `C-v` / `C-x`   Open in vertical / horizontal split
    `?`             View all mappings

## File explorer (nvim-tree)
  `,<space>`        Focus tree
  `,e`              Toggle tree (show / hide)
  `,w`              Reveal current file in tree

## Terminal (toggleterm)
  `,Tf`             Open terminal as float
  `,Th`             Open terminal as horizontal split
  `,Tv`             Open terminal as vertical split
  `,Tt`             Open terminal as tab
  `,Tn`             Rename current terminal (prompts)
  `<Esc><Esc>`      Exit terminal mode (back to nvim normal mode)
  `,fv`             Telescope picker for switching between terminals

## Editing
  `yc{motion}`      Yank to system clipboard
  `ga{motion}`      EasyAlign — e.g. `gaip2=` aligns paragraph at 2nd `=`
  `gS` / `gJ`       Split / join line (splitjoin)
  `,cc` / `,cu`     Comment / uncomment selection (NerdCommenter)

## Surround (nvim-surround)
  Opening bracket adds spaces, closing doesn't:
  `ysiw(` → `( word )`   `ysiw)` → `(word)`

  Add:
    `ysiw)`         Surround word with `()`
    `ys$)`          Surround to end of line with `()`
    `yss)`          Surround entire line with `()`
    `yS{motion}{c}` Same as `ys` but on new lines
    `S)` (visual)   Surround visual selection with `()`
    `C-g s )` (ins) Insert surround at cursor

  Delete:
    `ds(`           Delete surrounding `()`
    `ds]`           Delete surrounding `[]`
    `ds"`           Delete surrounding `""`
    `dst`           Delete surrounding HTML/XML tag

  Change:
    `cs)"`          Change surrounding `()` to `""`
    `cs"'`          Change surrounding `""` to `''`
    `cst<div>`      Change surrounding tag to `<div>`
    `csta`          Change surrounding tag's attributes

  Targets: `(` `[` `{` `<` `'` `"`   `t` (tag)   `f` (function call)

## Autocomplete
  `<Tab>` / `<S-Tab>`   Cycle completion menu
