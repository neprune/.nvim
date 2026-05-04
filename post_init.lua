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

-- Single-line floating input that supports vim normal-mode editing — much
-- nicer than vim.ui.input for renames where you want to dab/cw/etc.
-- <CR> (n+i) confirms, <Esc>/q (n) and <C-c> (any) cancel.
local function floating_input(opts, on_confirm)
  opts = opts or {}
  local default = opts.default or ""
  local title = opts.title or "Input"

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { default })

  local width = math.max(40, math.min(vim.o.columns - 10, #default + 30))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = 1,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor(vim.o.lines / 2) - 1,
    style = "minimal",
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
  })

  -- Disable cmp in this scratch buffer so its <CR> handler doesn't fight ours.
  pcall(function() require("cmp").setup.buffer({ enabled = false }) end)

  vim.api.nvim_win_set_cursor(win, { 1, #default })
  vim.cmd("startinsert!")

  local closed = false
  local function close(confirm)
    if closed then return end
    closed = true
    local value
    if confirm then
      value = (vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or "")
        :gsub("^%s+", ""):gsub("%s+$", "")
    end
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if confirm and on_confirm then on_confirm(value) end
  end

  local map = { buffer = buf, silent = true, nowait = true }
  vim.keymap.set({ "n", "i" }, "<CR>",  function() close(true)  end, map)
  vim.keymap.set({ "n", "i" }, "<C-c>", function() close(false) end, map)
  vim.keymap.set("n",          "<Esc>", function() close(false) end, map)
  vim.keymap.set("n",          "q",     function() close(false) end, map)

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = buf,
    once = true,
    callback = function() close(false) end,
  })
end

-- Native :terminal helpers. Capture cmd + cwd in buffer-local vars so the
-- resession extension can round-trip them on save/load (native :terminal
-- exposes neither after spawn).
local function start_terminal_in_current_window()
  vim.cmd("terminal")
  vim.b.term_cmd = vim.o.shell
  vim.b.term_cwd = vim.fn.getcwd()
end

vim.keymap.set("n", "<leader>rh", function()
  vim.cmd(math.floor(vim.o.lines * 0.5) .. "split")
  start_terminal_in_current_window()
end, { desc = "Terminal in horizontal split" })

vim.keymap.set("n", "<leader>rv", function()
  vim.cmd(math.floor(vim.o.columns * 0.5) .. "vsplit")
  start_terminal_in_current_window()
end, { desc = "Terminal in vertical split" })

vim.keymap.set("n", "<leader>rt", function()
  vim.cmd("tabnew")
  start_terminal_in_current_window()
end, { desc = "Terminal in new tab" })

vim.keymap.set("n", "<leader>rc", function()
  start_terminal_in_current_window()
end, { desc = "Terminal in current window" })

vim.keymap.set("n", "<leader>rn", function()
  if vim.bo.buftype ~= "terminal" then
    vim.notify("Not a terminal buffer", vim.log.levels.WARN)
    return
  end
  local current = vim.api.nvim_buf_get_name(0)
  floating_input({ title = "Rename terminal", default = current }, function(name)
    if not name or name == "" then return end
    -- :file renames the buffer; bufferline reads bufname so this propagates.
    local ok, err = pcall(vim.cmd, "file " .. vim.fn.fnameescape(name))
    if not ok then vim.notify(err, vim.log.levels.ERROR) end
  end)
end, { desc = "Rename current terminal" })

-- ',fv' — picker over open terminal buffers.
vim.keymap.set("n", "<leader>fv", function()
  local pickers      = require("telescope.pickers")
  local finders      = require("telescope.finders")
  local conf         = require("telescope.config").values
  local actions      = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local entries = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf)
        and vim.bo[buf].buftype == "terminal" then
      table.insert(entries, {
        bufnr = buf,
        name = vim.api.nvim_buf_get_name(buf),
      })
    end
  end

  if #entries == 0 then
    vim.notify("No terminal buffers", vim.log.levels.INFO)
    return
  end

  pickers.new({}, {
    prompt_title = "Terminals",
    finder = finders.new_table({
      results = entries,
      entry_maker = function(item)
        return { value = item, display = item.name, ordinal = item.name }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if entry then vim.api.nvim_set_current_buf(entry.value.bufnr) end
      end)
      return true
    end,
  }):find()
end, { desc = "Pick terminal buffer" })

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

-- ============================================================================
-- Workspaces
-- ============================================================================
-- A workspace = a vim tab page with a name + persisted snapshot. scope.nvim
-- scopes the buffer list to the current tab, so the bufferline at the top is
-- per-workspace. resession.nvim handles save/load by name; a small extension
-- below round-trips native :terminal state (name/cwd/cmd, no scrollback).

require("scope").setup({})

local resession = require("resession")

-- Use a dedicated dir name so file-based renames below have a known path.
local workspace_dir_name = "workspaces"
local workspace_dir_abs = vim.fn.stdpath("data") .. "/" .. workspace_dir_name

-- 'term' extension lives at lua/resession/extensions/term.lua and round-trips
-- native :terminal buffers (name + cwd + cmd) for the current tab page.
-- enable_in_tab: resession.save_tab() skips extensions without this flag.
resession.setup({
  dir = workspace_dir_name,
  autosave = { enabled = false },
  extensions = { term = { enable_in_tab = true } },
})

-- Workspace name is stored in `t:name`, which bufferline reads for the tab
-- indicator on the right.
local UNTITLED = "untitled"
local function set_workspace_name(tab, name)
  vim.t[tab].name = name or UNTITLED
end

local function tab_is_disposable(tabpage)
  -- Disposable = name is the placeholder AND no real buffers are open.
  -- Unlisted buffers (nvim-tree, oil, telescope prompts, etc.) don't count.
  if vim.t[tabpage].name and vim.t[tabpage].name ~= UNTITLED then
    return false
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buflisted
        and (vim.api.nvim_buf_get_name(buf) ~= "" or vim.bo[buf].modified) then
      return false
    end
  end
  return true
end

local function load_into_tab(name)
  -- Reuse the current tab if it's an empty 'untitled'; otherwise open a new tab.
  if not tab_is_disposable(vim.api.nvim_get_current_tabpage()) then
    vim.cmd("tabnew")
  end
  resession.load(name, { attach = false, reset = true })
  set_workspace_name(0, name)
end

-- Default any tab that doesn't have a workspace name to 'untitled'. Fires on
-- nvim startup (the initial tab) and on every :tabnew / TabNewEntered.
local function ensure_workspace_name(tab)
  tab = tab or 0
  if not vim.t[tab].name then
    set_workspace_name(tab, UNTITLED)
  end
end
vim.api.nvim_create_autocmd({ "VimEnter", "TabNewEntered" }, {
  callback = function() ensure_workspace_name(0) end,
})

-- Rename a workspace on disk. resession has no rename API; the saved files are
-- JSON in `workspace_dir_abs`, so we just move one file. Returns true on success.
local function rename_saved_workspace(old, new)
  local old_path = workspace_dir_abs .. "/" .. old .. ".json"
  local new_path = workspace_dir_abs .. "/" .. new .. ".json"
  if vim.uv.fs_stat(new_path) then
    vim.notify("Workspace '" .. new .. "' already exists", vim.log.levels.WARN)
    return false
  end
  local ok, err = vim.uv.fs_rename(old_path, new_path)
  if not ok then
    vim.notify("Rename failed: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end
  -- If any open tab is still pointing at the old name, update it.
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if vim.t[tab].name == old then
      set_workspace_name(tab, new)
    end
  end
  return true
end

local function save_workspace()
  local name = vim.t.name
  if name and name ~= UNTITLED then
    resession.save_tab(name, { notify = false })
    vim.notify("Saved workspace '" .. name .. "'")
    return
  end
  floating_input({ title = "Save workspace as" }, function(input)
    if not input or input == "" then return end
    set_workspace_name(0, input)
    resession.save_tab(input, { notify = false })
    vim.notify("Saved workspace '" .. input .. "'")
  end)
end

-- Telescope picker for workspaces. Default action loads; <C-r> renames the
-- highlighted workspace via the floating input; <C-d> deletes it.
local function open_workspace()
  local pickers       = require("telescope.pickers")
  local finders       = require("telescope.finders")
  local conf          = require("telescope.config").values
  local actions       = require("telescope.actions")
  local action_state  = require("telescope.actions.state")

  local function show()
    pickers.new({}, {
      prompt_title = "Workspaces  (<CR> open · <C-r> rename · <C-d> delete)",
      finder = finders.new_table({ results = resession.list() }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry then load_into_tab(entry[1]) end
        end)

        local function rename_action()
          local entry = action_state.get_selected_entry()
          if not entry then return end
          local old = entry[1]
          actions.close(prompt_bufnr)
          floating_input({ title = "Rename workspace", default = old }, function(new)
            if not new or new == "" or new == old then
              vim.schedule(show); return
            end
            if rename_saved_workspace(old, new) then
              vim.notify("Renamed '" .. old .. "' → '" .. new .. "'")
            end
            vim.schedule(show)
          end)
        end

        local function delete_action()
          local entry = action_state.get_selected_entry()
          if not entry then return end
          local name = entry[1]
          resession.delete(name, { notify = false })
          vim.notify("Deleted workspace '" .. name .. "'")
          actions.close(prompt_bufnr)
          vim.schedule(show)
        end

        map({ "i", "n" }, "<C-r>", rename_action)
        map({ "i", "n" }, "<C-d>", delete_action)
        return true
      end,
    }):find()
  end

  show()
end

-- Telescope picker for *open* workspaces (currently active tab pages).
-- Default action switches to the selected tab. A '+ New workspace' entry at
-- the top creates a fresh untitled tab.
local NEW_WORKSPACE = "+ New workspace"
local function switch_workspace()
  local pickers       = require("telescope.pickers")
  local finders       = require("telescope.finders")
  local conf          = require("telescope.config").values
  local actions       = require("telescope.actions")
  local action_state  = require("telescope.actions.state")

  local entries = { NEW_WORKSPACE }
  local tabs = vim.api.nvim_list_tabpages()
  local current = vim.api.nvim_get_current_tabpage()
  for _, tab in ipairs(tabs) do
    local name = vim.t[tab].name or UNTITLED
    local marker = (tab == current) and " (current)" or ""
    table.insert(entries, {
      tab = tab,
      label = name .. marker,
    })
  end

  pickers.new({}, {
    prompt_title = "Open workspaces",
    finder = finders.new_table({
      results = entries,
      entry_maker = function(item)
        if item == NEW_WORKSPACE then
          return { value = item, display = item, ordinal = "0_new" }
        end
        return { value = item, display = item.label, ordinal = item.label }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if not entry then return end
        if entry.value == NEW_WORKSPACE then
          vim.cmd("tabnew")  -- TabNewEntered autocmd will set name to 'untitled'
        else
          vim.cmd(vim.api.nvim_tabpage_get_number(entry.value.tab) .. "tabnext")
        end
      end)
      return true
    end,
  }):find()
end

vim.keymap.set("n", "<leader>Ws", save_workspace,      { desc = "Save workspace" })
vim.keymap.set("n", "<leader>Wo", open_workspace,      { desc = "Saved workspaces (open / rename / delete)" })
vim.keymap.set("n", "<leader>Ww", switch_workspace,    { desc = "Switch open workspace (or new)" })
vim.keymap.set("n", "<leader>Wx", "<cmd>tabclose<cr>", { desc = "Close tab (saved copy stays)" })

-- Configure nvim-cmp (autocomplete). Buffer + path + LSP sources.
local cmp = require("cmp")
cmp.setup({
  sources = {
    { name = "nvim_lsp" },
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

-- Terminal buffer defaults.
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    -- Native :terminal buffers default to unlisted; flip so they show in
    -- bufferline alongside files.
    vim.opt_local.buflisted = true
  end,
})

-- Double-Esc to leave terminal mode (single Esc is intercepted by shell vi mode).
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- which-key: popup of mappings when leader is held briefly.
require("which-key").setup({ delay = 500 })
require("which-key").add({
  { "<leader>c", group = "config" },
  { "<leader>f", group = "find (telescope)" },
  { "<leader>g", group = "git (gitsigns)" },
  { "<leader>l", group = "LSP" },
  { "<leader>m", group = "window (wasd)" },
  { "<leader>r", group = "terminal" },
  { "<leader>t", group = "tabs" },
  { "<leader>W", group = "workspace" },
  { "<leader>x", group = "trouble (diagnostics)" },
  { "<leader>b", group = "buffer" },
})

-- Comment.nvim: 'gcc' line, 'gc{motion}' operator, 'gc' visual.
require("Comment").setup()

-- gitsigns: sign-column markers, hunk staging, blame.
require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
    end
    map("]c", function() gs.nav_hunk("next") end, "Next git hunk")
    map("[c", function() gs.nav_hunk("prev") end, "Previous git hunk")
    map("<leader>gs", gs.stage_hunk,        "Stage hunk")
    map("<leader>gr", gs.reset_hunk,        "Reset hunk")
    map("<leader>gp", gs.preview_hunk,      "Preview hunk")
    map("<leader>gb", gs.toggle_current_line_blame, "Toggle line blame")
  end,
})

-- LSP: mason auto-installs servers (':Mason' UI), mason-lspconfig wires them up,
-- nvim-lspconfig configures the client. cmp-nvim-lsp expands client capabilities.
require("mason").setup()
require("mason-lspconfig").setup({ automatic_enable = true })
local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
vim.lsp.config("*", { capabilities = lsp_capabilities })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
    end
    map("gd", vim.lsp.buf.definition,     "LSP: go to definition")
    map("gD", vim.lsp.buf.declaration,    "LSP: go to declaration")
    map("gr", vim.lsp.buf.references,     "LSP: list references")
    map("gi", vim.lsp.buf.implementation, "LSP: go to implementation")
    map("K",  vim.lsp.buf.hover,          "LSP: hover docs")
    map("<leader>lr", vim.lsp.buf.rename,      "LSP: rename symbol")
    map("<leader>la", vim.lsp.buf.code_action, "LSP: code action")
    map("<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "LSP: format buffer")
  end,
})

-- trouble.nvim: better diagnostics / quickfix UI. Bindings live in init.vim.
require("trouble").setup()

-- flash.nvim: 's' = jump, 'S' = treesitter jump.
-- Setup only auto-binds f/F/t/T/;/, — s/S keymaps shown in the README come from a
-- lazy.nvim 'keys' block, so vim-plug users have to wire them up by hand.
require("flash").setup()
vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end,
  { desc = "Flash jump" })
vim.keymap.set({ "n", "x", "o" }, "S", function() require("flash").treesitter() end,
  { desc = "Flash treesitter jump" })

-- mini.nvim modules (selective).
require("mini.bufremove").setup()
require("mini.pairs").setup()
require("mini.move").setup()
vim.keymap.set("n", "<leader>bd", function() require("mini.bufremove").delete() end,
  { desc = "Delete buffer (keep window)" })

-- oil.nvim: edit your filesystem like a buffer; '-' opens parent dir.
require("oil").setup()
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent dir (oil)" })

-- indent-blankline: subtle vertical indent guides.
require("ibl").setup()

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

