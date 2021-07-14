---@brief [[
--- Telescope-hop.nvim allows you to fully configure the default options for `telescope-hop.actions`.
---@brief ]]

---@tag telescope-hop.config

local config = {}

--- Setup function for `telescope-hop.nvim`.
--- - Highlight groups (`sign_hl`, `line_hl`):
---   - Commonly, line_hl is a version of sign_hl that only sets the background to not override results foreground
--- - `hop_loop`-specific: 
---     - `trace_entry`, `reset_selection` and `escape_keys` only affect `actions._hop_loop`
---     - The termcodes for passed strings of `escape_keys` are replaced, which defaults to {<CR>, "<ESC>", "<C-c>"}
--- - Global Defaults
---   - sign_hl: QuestionMsg
---   - line_hl: nil
---   - sign_virt_text_pos: "overlay" (see `vim.api.nvim_buf_set_extmark`)
---   - clear_selection_hl: true
--- - Hop-loop-specific Defaults
---   - trace_entry: false
---   - reset_selection: true
---   - escape_keys: {"<ESC>", "<C-c>"}
---   - accept_keys: {"<CR>"}
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
---@param opts table: extension configuration
---@field keys table: table of chars in order to hop to, roughly defaults to lower and upper-cased home row
---@field sign_hl string|table: hl group to link hop chars to; if table, must be two groups that are alternated between
---@field line_hl nil|string|table: analogous to sign_hl; in addition, `nil` results in no line highlighting
---@field sign_virt_text_pos string: if "right_align" then hop char aligned to right, else left aligned
---@field trace_entry boolean: `hop_loop` only, entry hopped to will be highlighted via telescope selection hl groups
---@field reset_selection boolean: `hop_loop` only, return to entry selected before entering `hop` loop
---@field escape_keys table: `hop_loop` only, set of key chords (termcodes are replaced) that finish loop
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
