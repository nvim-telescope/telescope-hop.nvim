---@tag telescope-hop.config

---@brief [[
--- Telescope-hop.nvim allows you to fully configure the default options for `telescope-hop.actions`.
---@brief ]]


local config = {}

--- Setup function for `telescope-hop.nvim`.
--- - Notes:
---     - `trace_entry`, `reset_selection` and `escape_keys` only affect `actions._hop_loop`
---     - The termcodes for passed strings of `escape_keys` are replaced, which defaults to {<CR>, "<ESC>", "<C-c>"}
--- - Highlight groups (`sign_hl`, `line_hl`):
---   - Link `sign_hl` and `line_hl` to their respective highlight groups
---   - Setting `sign_hl` and `line_hl` to a table of two highlight groups results in alternating highlighting
---   - Setting `link_hl` to nil does not set any line highlighting
--- - `hop_loop`-specific: 
--
--- <pre>
--- Example:
---   require("telescope").setup {
---     extensions = {
---       hop = {
---         sign_hl = { "WarningMsg", "Title" },
---         line_hl = { "CursorLine", "Normal" },
---         clear_selection_hl = false,
---         trace_entry = true,
---         reset_selection = true,
---       },
---     }
---   }
--- </pre>
---
---@param opts table: extension configuration
---@field keys table: table of chars in order to hop to (default: roughly lower- & upper-cased home row)
---@field sign_hl string|table: hl group to link hop chars to (default: `"QuestionMsg"`)
---@field line_hl nil|string|table: analogous to sign_hl (default: `nil`)
---@field sign_virt_text_pos string: if "right_align" then hop char aligned to right else left (default: `"overlay"`)
---@field trace_entry boolean: entry hopped to will be highlighted via telescope selection hl groups (default: `false`)
---@field clear_selection boolean: temporarily clear Telescope selection highlight group (default: `true`)
---@field reset_selection boolean: return to entry selected before entering `hop` loop (default: `true`)
---@field escape_keys table: key chords that interrupt loop before `loop_callback` (default: `{"<ESC>", "<C-c>"`}`)
---@field accept_keys table: key chords that finish loop and execute `loop_callback if passed (default: `{"<CR>"}`)
config.setup = function(opts)
  -- general configuration
  config.keys = vim.F.if_nil(opts.keys, {
    "a", "s", "d", "f", "g", "h", "j", "k", "l", ";",
    "q", "w", "e", "r", "t", "y", "u", "i", "o", "p",
    "A", "S", "D", "F", "G", "H", "J", "K", "L", ":",
    "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P",
  })
  config.sign_hl = vim.F.if_nil(opts.sign_hl, "QuestionMsg")
  config.line_hl = opts.line_hl
  config.sign_virt_text_pos = opts.sign_virt_text_pos == "right_align" and "right_align"
    or "overlay"
  config.clear_selection_hl = vim.F.if_nil(opts.clear_selection_hl, true)
  -- hop loop specific configuration
  config.trace_entry = vim.F.if_nil(opts.trace_entry, false)
  config.reset_selection = vim.F.if_nil(opts.reset_selection, true)
  config.escape_keys = vim.tbl_map(function(key)
    return vim.api.nvim_replace_termcodes(key, true, false, true)
  end, vim.F.if_nil(opts.escape_keys, {"<ESC>", "<C-c>"}))
  config.accept_keys = vim.tbl_map(function(key)
    return vim.api.nvim_replace_termcodes(key, true, false, true)
  end, vim.F.if_nil(opts.escape_keys, {"<CR>"}))
end

return config
