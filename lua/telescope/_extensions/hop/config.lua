---@brief [[
--- Telescope-hop.nvim allows you to fully configure the default options for |telescope-hop.actions|.
--- The extension
---@brief ]]

---@tag telescope-hop.setup

-- config table named `telescope_hop` for more suitable docgen
local telescope_hop = {}

--- Setup function for |telescope-hop.nvim|.
--- - Note:
---     - `trace_entry`, `reset_selection` and `escape_keys` only affect |hop_actions._hop_loop|
---     - The termcodes for passed strings of `escape_keys` are replaced, which defaults to {"<CR>", "<ESC>", "<C-c>"}
--- - Highlight groups (`sign_hl`, `line_hl`):
---   - Link `sign_hl` and `line_hl` to their respective highlight groups
---   - Setting `sign_hl` and `line_hl` to a table of two highlight groups results in alternating highlighting
---   - Setting `link_hl` to nil does not set any line highlighting
--- <pre>
---
--- Example:
---   require("telescope").setup {
---     extensions = {
---       hop = {
---         -- define your hop keys in order
---         keys = { "a", "s", "d", "f", "g", "h", "j", "k", "l", ";"}
---         -- Highlight groups to link to signs and lines
---         -- Tables of two highlight groups induces
---         -- alternating highlighting by line
---         sign_hl = { "WarningMsg", "Title" },  
---         line_hl = { "CursorLine", "Normal" }, 
---         -- options specific to `hop_loop`
---         clear_selection_hl = false,
---         trace_entry = true,
---         reset_selection = true,
---       },
---     }
---   }
--- To get the extension loaded and working with telescope, you need to call
--- load_extension, somewhere after setup function:
---   require('telescope').load_extension('hop')
--- </pre>
---@param opts table: extension configuration
---@field keys table: table of chars in order to hop to (default: roughly lower- & upper-cased home row)
---@field sign_hl string|table: hl group to link hop chars to (default: `"Search"`)
---@field line_hl nil|string|table: analogous to sign_hl (default: `nil`)
---@field sign_virt_text_pos string: if "right_align" then hop char aligned to right else left (default: `"overlay"`)
---@field trace_entry boolean: entry hopped to will be highlighted via telescope selection hl groups (default: `false`)
---@field clear_selection boolean: temporarily clear Telescope selection highlight group (default: `true`)
---@field reset_selection boolean: return to entry selected before entering `hop` loop (default: `true`)
---@field escape_keys table: key chords that interrupt loop before `loop_callback` (default: `{"<ESC>", "<C-c>"`}`)
---@field accept_keys table: key chords that finish loop and execute `loop_callback if passed (default: `{"<CR>"}`)
telescope_hop.setup = function(opts)
  -- general telescope_hopuration
  telescope_hop.keys = vim.F.if_nil(opts.keys, { 
    "a", "s", "d", "f", "g", "h", "j", "k", "l", ";",
    "q", "w", "e", "r", "t", "y", "u", "i", "o", "p",
    "A", "S", "D", "F", "G", "H", "J", "K", "L", ":",
    "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", })
  telescope_hop.sign_hl = vim.F.if_nil(opts.sign_hl, "Search")
  telescope_hop.line_hl = opts.line_hl
  telescope_hop.sign_virt_text_pos = opts.sign_virt_text_pos == "right_align" and "right_align"
    or "overlay"
  telescope_hop.clear_selection_hl = vim.F.if_nil(opts.clear_selection_hl, true)
  -- hop loop specific configuration
  telescope_hop.trace_entry = vim.F.if_nil(opts.trace_entry, false)
  telescope_hop.reset_selection = vim.F.if_nil(opts.reset_selection, true)
  telescope_hop.escape_keys = vim.tbl_map(function(key)
    return vim.api.nvim_replace_termcodes(key, true, false, true)
  end, vim.F.if_nil(
    opts.escape_keys,
    { "<ESC>", "<C-c>" }
  ))
  telescope_hop.accept_keys = vim.tbl_map(function(key)
    return vim.api.nvim_replace_termcodes(key, true, false, true)
  end, vim.F.if_nil(
    opts.escape_keys,
    { "<CR>" }
  ))
end

return telescope_hop
