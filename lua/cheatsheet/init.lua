local M = {}
local ns = vim.api.nvim_create_namespace("cheatsheet")
local last_tab_idx = 1

-- Returns lines[] and hls[] (0-indexed {row, col_start, col_end, hl_group}) for section items only.
local function section_lines(section)
  local lines = {}
  local hls = {}

  local max_keys = 0
  for _, item in ipairs(section.items) do
    if item.keys then
      max_keys = math.max(max_keys, vim.fn.strdisplaywidth(item.keys))
    end
  end

  for _, item in ipairs(section.items) do
    if item.note then
      lines[#lines + 1] = "  " .. item.note
    else
      local row = #lines
      local pad = string.rep(" ", max_keys - vim.fn.strdisplaywidth(item.keys) + 2)
      lines[#lines + 1] = "  " .. item.keys .. pad .. item.desc
      hls[#hls + 1] = { row, 2, 2 + #item.keys, "CheatCode" }
    end
  end

  return lines, hls
end

local function apply(buf, lines, hls)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, hl in ipairs(hls) do
    vim.api.nvim_buf_set_extmark(buf, ns, hl[1], hl[2], {
      end_col = hl[3],
      hl_group = hl[4],
    })
  end
end

local function build_unified(data)
  local lines = {}
  local hls = {}

  for _, section in ipairs(data) do
    local header_row = #lines
    local header = "  " .. section.title
    lines[#lines + 1] = header
    hls[#hls + 1] = { header_row, 0, #header, "CheatSection" }

    local slines, shls = section_lines(section)
    local offset = #lines
    for _, hl in ipairs(shls) do
      hls[#hls + 1] = { offset + hl[1], hl[2], hl[3], hl[4] }
    end
    for _, l in ipairs(slines) do
      lines[#lines + 1] = l
    end
    lines[#lines + 1] = ""
  end

  return lines, hls
end

local function count_lines(data)
  local n = 0
  for _, section in ipairs(data) do
    n = n + 2 + #section.items  -- header + items + blank separator
  end
  return n
end

local function setup_tabbed(buf, data)
  local state = { idx = last_tab_idx }

  local function render()
    local lines = {}
    local hls = {}

    -- Tab bar: [Abbr] for active, Abbr for inactive, single-space separator.
    local bar = ""
    local positions = {}
    for i, section in ipairs(data) do
      local abbr = section.abbr or section.title:sub(1, 4)
      local sep = i > 1 and " " or ""
      local label = i == state.idx and ("[" .. abbr .. "]") or abbr
      positions[i] = { #bar + #sep, #bar + #sep + #label }
      bar = bar .. sep .. label
    end
    lines[1] = bar
    lines[2] = ""

    for i, pos in ipairs(positions) do
      hls[#hls + 1] = { 0, pos[1], pos[2], i == state.idx and "CheatTitle" or "CheatSection" }
    end

    -- Active section body (no repeated header; the tab bar already names it).
    local slines, shls = section_lines(data[state.idx])
    local offset = #lines
    for _, hl in ipairs(shls) do
      hls[#hls + 1] = { offset + hl[1], hl[2], hl[3], hl[4] }
    end
    for _, l in ipairs(slines) do
      lines[#lines + 1] = l
    end

    apply(buf, lines, hls)
  end

  render()

  local function go(delta)
    state.idx = ((state.idx - 1 + delta) % #data) + 1
    last_tab_idx = state.idx
    render()
  end

  local opts = { buffer = buf, nowait = true }
  vim.keymap.set("n", "h",       function() go(-1) end, opts)
  vim.keymap.set("n", "l",       function() go(1) end,  opts)
  vim.keymap.set("n", "<Tab>",   function() go(1) end,  opts)
  vim.keymap.set("n", "<S-Tab>", function() go(-1) end, opts)
end

function M.create_buf(win_height)
  local data = require("cheatsheet.data")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].modifiable = false

  if count_lines(data) <= win_height then
    local lines, hls = build_unified(data)
    apply(buf, lines, hls)
  else
    setup_tabbed(buf, data)
  end

  return buf
end

return M
