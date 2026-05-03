# Cheatsheet

Leader is `,`. Press `,,` to toggle this view. Edit freely; `:w` saves to disk.
Hold `,` (or any prefix) and pause for a moment — which-key shows what's available.

## General
  `jj`              Escape insert mode
  `,,`              Toggle this cheatsheet
  `,q`              Close current split

## Splits & tabs
  `,v` / `,s`       New vertical / horizontal split
  `,tn`             New tab
  `,t1`..`,t9`      Switch to tab 1..9
  `,t0`             Switch to last tab
  `,m{w,a,s,d}`     Window navigation (up / left / down / right)

## Buffers
  `,1`..`,9`        Switch to visible buffer 1..9 (renumbers as buffers close)
  `,0`              Switch to visible buffer 10
  `,bd`             Delete current buffer, keep the window (mini.bufremove)

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

## Filesystem-as-buffer (oil.nvim)
  `-`               Open parent directory as an oil buffer

  Inside an oil buffer you edit the listing like text:
    Rename a file by editing its name.
    Delete a file by deleting its line.
    Move a file by cutting and pasting between oil buffers.
    Press `:w` to apply changes to disk.
    Press `-` again to go up another level.

## Quick jump (flash.nvim)
  `s` + chars       Jump to any position on screen — type `s` then the
                    start of what you want; press the shown label key to teleport.
  `S`               Jump to a treesitter node (function names, blocks, etc).

  Note: `s` overrides vim's default substitute-char (use `cl` instead).

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
  `gcc`             Toggle line comment (Comment.nvim)
  `gc{motion}`      Comment a region — e.g. `gcip` for paragraph
  `gc` (visual)     Comment current selection
  `Alt+h/j/k/l`     Move current line / visual selection (mini.move)

  Auto-pairs: typing `(`, `[`, `{`, `"`, `'` auto-inserts the closing pair (mini.pairs).
  Indent settings auto-detect per file (vim-sleuth).
  Indent guides drawn at every level (indent-blankline).

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

## Git (gitsigns)
  `]c` / `[c`       Next / previous changed hunk
  `,gs`             Stage hunk under cursor
  `,gr`             Reset hunk under cursor
  `,gp`             Preview hunk in a popup
  `,gb`             Toggle inline blame for the current line

  The sign column shows `+` / `~` / `_` markers per added / changed / deleted line.
  For full-repo git operations, use `:Git status`, `:Git blame`, etc. (vim-fugitive).

## LSP (language server protocol)
  Set up servers per language with `:Mason` (UI) or `:MasonInstall <name>`.
  Once a server attaches to a buffer, these bindings activate:

  Navigation:
    `gd`            Go to definition
    `gD`            Go to declaration
    `gr`            List references
    `gi`            Go to implementation
    `K`             Hover docs (press `K` again to enter the popup)

  Refactoring:
    `,lr`           Rename symbol (across the workspace)
    `,la`           Code action (quick fixes, refactors)
    `,lf`           Format buffer

  Diagnostics inline + virtual-text are on by default; trouble.nvim shows the panel.

## Diagnostics (trouble.nvim)
  `,xx`             Toggle workspace diagnostics panel
  `,xd`             Document-only diagnostics
  `,xq`             Quickfix list in trouble
  `,xl`             Location list in trouble

  Inside trouble: `<CR>` jump, `q` close, `?` help.

## Autocomplete (nvim-cmp)
  `<Tab>` / `<S-Tab>`   Cycle completion menu
  `<CR>`                Confirm selection (only when one is highlighted)

  Sources: buffer words, file paths, active LSP servers.
