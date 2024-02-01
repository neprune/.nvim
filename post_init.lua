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

-- Alywas open nvim.tree.
local function open_nvim_tree()
  require("nvim-tree.api").tree.open()
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

-- Configure toggleterm.
require("toggleterm").setup{
  size = 50,
  direction = 'float',
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

-- Setup custom terminals.
-- local Terminal  = require('toggleterm.terminal').Terminal
