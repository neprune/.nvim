-- Silence deprecation noise from older plugins (project.nvim, plenary, etc.) that haven't
-- caught up to nvim 0.11's renamed APIs. Both functions still work; we just route around the warning.
vim.lsp.buf_get_clients = function(bufnr)
  return vim.lsp.get_clients({ bufnr = bufnr })
end
vim.tbl_flatten = function(t)
  return vim.iter(t):flatten(math.huge):totable()
end
vim.tbl_islist = vim.islist

-- Default project.nvim configuration.
require("project_nvim").setup{manual_mode=false, patterns={".git", ".project"}}

-- Add project.nvim extension to telescope.
require('telescope').load_extension('projects')


-- Configure nvim.tree for project.nvim.
require("nvim-tree").setup{
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = true
  }
}

-- Open nvim-tree on startup, but only when no file argument was passed.
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      require("nvim-tree.api").tree.open()
    end
  end,
})

-- Configure toggleterm.
require("toggleterm").setup{
  size = 50,
  direction = 'float',
  shade_terminals = false,
  winbar = {
    enabled = true,
    name_formatter = function(term) --  term: Terminal
        return term.name
    end
  }
}

-- Add a telescope picker for toggleterms.
require('telescope').load_extension("termfinder")

-- Add a telescope picker for live_grep_args.
require('telescope').load_extension("live_grep_args")

-- Needed for nvim-surround to work.
require("nvim-surround").setup({})

-- Setup image previews.
require("image_preview").setup({})

-- Configure bufferline (IDE-like tabs). Ordinal numbering renumbers as buffers close.
require("bufferline").setup({
  options = {
    numbers = "ordinal",
    diagnostics = false,
    show_buffer_close_icons = false,
    show_close_icon = false,
  },
})

-- Configure nvim-cmp (autocomplete). Buffer + path sources, no LSP / snippets.
local cmp = require("cmp")
cmp.setup({
  sources = {
    { name = "buffer" },
    { name = "path" },
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item() else fallback() end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_prev_item() else fallback() end
    end, { "i", "s" }),
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
  }),
})

-- Configure treesitter.
require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "vim", "vimdoc", "json", "fish", "puppet" },
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = true },
})

-- Hide line numbers in terminals.
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

-- Double-Esc to leave terminal mode (single Esc is intercepted by shell vi mode).
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Cheatsheet floating window, bound to ',,' (toggles, ':w' saves edits).
local cheat_win = nil

local function show_cheatsheet()
  if cheat_win and vim.api.nvim_win_is_valid(cheat_win) then
    vim.api.nvim_win_close(cheat_win, true)
    cheat_win = nil
    return
  end

  -- Re-applied each call: ':colorscheme' runs ':hi clear' and would otherwise wipe these.
  vim.api.nvim_set_hl(0, "CheatTitle",   { fg = "#b58900", bold = true })  -- solarized yellow
  vim.api.nvim_set_hl(0, "CheatSection", { fg = "#268bd2", bold = true })  -- solarized blue
  vim.api.nvim_set_hl(0, "CheatCode",    { fg = "#859900" })               -- solarized green

  local path = vim.fn.stdpath("config") .. "/cheatsheet.md"
  local buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)
  vim.bo[buf].filetype = "cheatsheet"

  local width = math.min(110, vim.o.columns - 4)
  local height = vim.o.lines - 4
  cheat_win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " Cheatsheet  (,, to toggle  ·  :w to save) ",
    title_pos = "center",
  })
  vim.wo[cheat_win].winhighlight = "FloatBorder:CheatSection,FloatTitle:CheatTitle"

  vim.api.nvim_buf_call(buf, function()
    vim.cmd([[
      syntax clear
      syntax match CheatTitle   /^#\s.*$/
      syntax match CheatSection /^##\s.*$/
      syntax match CheatCode    /`[^`]\+`/
    ]])
  end)
end

vim.keymap.set("n", "<leader><leader>", show_cheatsheet, { desc = "Toggle cheatsheet" })

