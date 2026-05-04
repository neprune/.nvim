# Neovim config reference

Prose that was trimmed from the cheatsheet. This file is for reading, not rendered in the modal.

---

## Buffers & scope.nvim

Buffers are scoped to the current tab page via scope.nvim. The bufferline at the top shows only the buffers belonging to the active tab, not the full list. Switching Neovim tabs switches to a different buffer scope. `,bd` (mini.bufremove) deletes the buffer while keeping the window open — unlike `:bd` which also closes the window.

---

## Workspaces (resession)

A workspace is a vim tab page that has been given a name and a persisted snapshot of its open files and terminal shells. The workspace name appears as the tab indicator label on the right of the bufferline. New tabs start as `untitled`.

**Picker sub-actions for `,Wo`** (saved workspaces on disk):
- `<CR>` — open in current tab if it's a disposable untitled; otherwise open in a new tab
- `<C-r>` — rename the highlighted saved workspace
- `<C-d>` — delete the highlighted saved workspace

**Floating prompts** (terminal rename, workspace save) support full vim editing: `jj` to escape to normal mode, use motions to edit the text, `<CR>` to confirm, `<Esc>` (normal mode) or `<C-c>` (any mode) to cancel.

---

## Oil.nvim

Oil opens the filesystem as an editable buffer. The listing is plain text — edit it like any file:

- **Rename** a file: edit its name in the buffer
- **Delete** a file: delete its line
- **Move** a file: cut the line, paste it into another oil buffer opened in a split
- **Create** a file: add a new line with the desired name (no leading path)
- Press `:w` to apply all pending changes to disk
- Press `-` again to go up to the parent directory

Changes are not applied until `:w` — you can stage multiple renames/deletes in one pass.

---

## Telescope picker bindings

Inside any Telescope picker:

| Key        | Action                            |
|------------|-----------------------------------|
| `C-t`      | Open result in new tab            |
| `C-v`      | Open result in vertical split     |
| `C-x`      | Open result in horizontal split   |
| `?`        | View all available mappings       |

---

## Git sign column

The sign column (left gutter) shows per-line change markers relative to HEAD:

- `+` — added line
- `~` — changed line
- `_` — deleted line (shown on the line below the deletion)

For full-repo operations (log, blame, diff, push, pull), use vim-fugitive: `:Git status`, `:Git blame`, `:Git log`, etc.

---

## LSP setup

Servers are managed by Mason. Use `:Mason` to open the UI, or `:MasonInstall <server-name>` directly (e.g. `:MasonInstall pyright`). Once a server attaches to a buffer, the `gd`/`gr`/`,lr`/etc. bindings activate automatically.

Inline diagnostics (underlines + virtual text) are on by default. trouble.nvim (`,xx`) shows a panel view of all diagnostics for the workspace or current document.

---

## Autocomplete sources (nvim-cmp)

Completions are pulled from:
- Buffer words (words visible in open buffers)
- File paths (relative and absolute)
- Active LSP server(s) for the current buffer

`<CR>` only confirms a completion when an entry is explicitly highlighted in the menu — pressing `<CR>` on a blank line or with no selection still inserts a newline normally.

---

## Editing defaults

- **Auto-pairs** (mini.pairs): typing `(`, `[`, `{`, `"`, or `'` auto-inserts the closing pair and positions the cursor inside.
- **Indent detection** (vim-sleuth): tab width and expand-tab are inferred from the file's existing indentation on open. No manual `set tabstop` needed.
- **Indent guides** (indent-blankline): subtle vertical lines drawn at every indentation level.
