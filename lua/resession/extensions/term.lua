-- Resession extension that round-trips native :terminal buffers for the
-- current tab page. Native :terminal exposes neither cmd nor cwd after spawn,
-- so we rely on b:term_cmd / b:term_cwd being set at spawn time by the
-- ',rh'/',rv'/',rt'/',rc' keymaps in post_init.lua.

local M = {}

function M.on_save()
  local out = {}
  local seen = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if not seen[buf] and vim.bo[buf].buftype == "terminal" then
      seen[buf] = true
      table.insert(out, {
        name = vim.api.nvim_buf_get_name(buf),
        cwd = vim.b[buf].term_cwd or vim.fn.getcwd(),
        cmd = vim.b[buf].term_cmd,
      })
    end
  end
  return out
end

function M.on_post_load(data)
  if not data or #data == 0 then return end
  local current_win = vim.api.nvim_get_current_win()
  local original_buf = vim.api.nvim_win_get_buf(current_win)
  for _, t in ipairs(data) do
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_win_set_buf(current_win, buf)
    local cmd = t.cmd or vim.o.shell
    vim.fn.termopen(cmd, { cwd = t.cwd })
    vim.b[buf].term_cmd = cmd
    vim.b[buf].term_cwd = t.cwd
    if t.name and t.name ~= "" then
      pcall(vim.cmd, "file " .. vim.fn.fnameescape(t.name))
    end
  end
  -- Empty no-name buffers get wiped when they leave a window, so the original
  -- may be gone by now. Leave the last terminal visible if so.
  if vim.api.nvim_buf_is_valid(original_buf) then
    vim.api.nvim_win_set_buf(current_win, original_buf)
  end
end

return M
