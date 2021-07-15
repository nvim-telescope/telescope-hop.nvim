---@brief [[
--- Telescope-hop.nvim actions that help you navigate and perform actions on results from telescope pickers.
--- |telescope-hop.actions| are typically composed with other telescope actions.
---
---@brief ]]

---@tag telescope-hop.actions

-- telescope modules
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local action_utils = require "telescope.actions.utils"

--- Telescope-hop.nvim actions (|hop_actions|) are canonically accessed via `R"telescope".extensions.hop`, where `R`
--- constitutes hot-reloading via plenary to ensure the config is setup adequately.
--- <pre>
---
--- if pcall(require, "plenary") then
---  R = function(name)
---    require("plenary.reload").reload_module(name)
---    return require(name)
---  end
---end
--- </pre>
local hop_actions = {}
local hop_config = require "telescope._extensions.hop.config"

--- Hop.nvim-style single char motion to entry in results window.
--- - Note: pressing any key not in `keys` silently interrupts hopping
--- - Highlight groups (`sign_hl`, `line_hl`):
---   - String: single uniform highlighting of hop sign or lines
---   - Table: must comprise two highlight groups to configure alternate highlighting of signs or lines
--- <pre>
---
--- Example Usage: select entry by hopping
---   require("telescope").setup {
---     defaults = {
---       mappings = {
---         i = {
---           ['<C-space>'] = function(prompt_bufnr)
---             require'telescope'.extensions.hop._hop(prompt_bufnr, {callback = actions.select_default)
---           end
---         },
---       },
---     },
---   }
--- </pre>
---@param prompt_bufnr number: The prompt bufnr
---@param opts table: options to pass to hop
---@field keys table: table of chars in order to hop to, roughly defaults to lower and upper-cased home row
---@field sign_hl string|table: hl group to link hop chars to (default: `"Search"`)
---@field line_hl nil|string|table: analogous to sign_hl (default: `nil`)
---@field sign_virt_text_pos string: if "right_align" then hop char aligned to right else left (default: `"overlay"`)
---@field clear_selection boolean: temporarily clear Telescope selection highlight group (default: `true`)
---@field callback function: `function(prompt_bufnr) ... end` that uses hopped-to-entry (default: `nil`)
---@return string: the pressed key
hop_actions._hop = function(prompt_bufnr, opts)
  opts = opts or {}
  opts.keys = vim.F.if_nil(opts.keys, hop_config.keys)
  opts.sign_hl = vim.F.if_nil(opts.sign_hl, hop_config.sign_hl)
  opts.line_hl = vim.F.if_nil(opts.line_hl, hop_config.line_hl)
  opts.sign_virt_text_pos = vim.F.if_nil(opts.sign_virt_text_pos, hop_config.sign_virt_text_pos)
  opts.clear_selection_hl = vim.F.if_nil(opts.clear_selection_hl, hop_config.clear_selection_hl)

  -- validate hl groups
  local val_hl = function(hl)
    local t = type(hl)
    if t == "string" or t == "nil" then
      return true
    end
    if t == "table" then
      if not #t == 2 then
        print "A table of highlight groups must comprise two highlight groups"
        return false
      end
      return true
    end
  end
  vim.validate {
    opts = { opts, "table" },
    [opts.keys] = { opts.keys, "table" },
    [opts.sign_hl] = {
      opts.sign_hl,
      val_hl,
      "Passed highlight groups have to be either string or tables",
    },
    -- line_hl can be nil => pass arg name explicitly
    ["line_hl"] = {
      opts.line_hl,
      val_hl,
      "Passed highlight groups have to be either string or tables",
    },
  }

  -- telescope state
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  local max_results = current_picker.max_results
  local num_results = current_picker.manager:num_results()
  local results_bufnr = current_picker.results_bufnr
  local sorting_strategy = current_picker.sorting_strategy

  -- namespaces
  local ns = vim.api.nvim_create_namespace "teleshopping"
  local ns_line_hl = vim.api.nvim_create_namespace "teleshopping_line_hl"
  local telescope_selection_ns = vim.api.nvim_create_namespace "telescope_selection"

  if opts.clear_selection_hl then
    vim.api.nvim_buf_clear_namespace(results_bufnr, telescope_selection_ns, 0, -1)
  end

  local keyline = {}
  for i = 1, math.min(num_results, max_results, #opts.keys) do
    local key = opts.keys[i]
    local linenr = sorting_strategy == "descending" and max_results - i or i

    local sign_hl = type(opts.sign_hl) == "table" and opts.sign_hl[math.pow(2, i % 2)]
      or opts.sign_hl
    vim.api.nvim_buf_set_extmark(results_bufnr, ns, linenr, 0, {
      virt_text = { { key, sign_hl } },
      virt_text_pos = opts.sign_virt_text_pos,
      hl_mode = "combine",
    })

    if opts.line_hl ~= nil then
      local line_hl = type(opts.line_hl) == "table" and opts.line_hl[math.pow(2, i % 2)]
        or opts.line_hl
      -- full line highlighting
      vim.api.nvim_buf_add_highlight(results_bufnr, ns_line_hl, line_hl, linenr, 0, -1) -- text
      vim.api.nvim_buf_set_extmark(
        results_bufnr,
        ns_line_hl,
        linenr,
        0, -- beyond text
        {
          hl_group = line_hl,
          hl_eol = true,
          virt_text = { { "", line_hl } },
          virt_text_pos = "overlay",
        }
      )
    end

    keyline[key] = linenr
  end
  -- ensure marks are drawn before getchar is executed
  vim.cmd [[redraw]]

  local char = vim.fn.getchar()
  local key = vim.fn.nr2char(char)

  if keyline[key] ~= nil then
    current_picker:set_selection(keyline[key])
    if opts.callback ~= nil then
      opts.callback(prompt_bufnr)
    end
  end

  -- callback can delete results_bufnr
  if vim.api.nvim_buf_is_valid(results_bufnr) then
    vim.api.nvim_buf_clear_namespace(results_bufnr, ns, 0, -1)
    vim.api.nvim_buf_clear_namespace(results_bufnr, ns_line_hl, 0, -1)
    -- restore selection hl
    -- if opts.clear_selection_hl then
    --   local caret = current_picker.selection_caret
    --   local row = current_picker:get_selection_row()
    --   current_picker.highlighter:hi_selection(row, caret:sub(1, -2))
    -- end
  end
  return key
end

--- Hop.nvim-style single char motion to entry in results buffer.
--- - Note: hops with set defaults, use |hop_actions._hop| for passing opts on-the-fly
--- <pre>
---
--- Example Usage:
---   require("telescope").setup {
---     defaults = {
---       mappings = {
---         i = {
---           ['<C-space>'] = R"telescope".extensions.hop.hop
---         },
---       },
---     },
---   }
--- </pre>
hop_actions.hop = function(prompt_bufnr)
  hop_actions._hop(prompt_bufnr, {})
end

--- Levers |hop_actions._hop| to sequentially do `callback` on entry until escape keys are registered.
--- - Note:
---     - The termcodes for passed strings of `escape_keys` are replaced, which defaults to {<CR>, "<ESC>", "<C-c>"}
--- <pre>
---
--- Example Usage: toggle selection with hop and send selected to qflist
---   require("telescope").setup {
---     defaults = {
---       mappings = {
---         i = {
---           ["<C-space>"] = function(prompt_bufnr)
---             local opts = {
---               callback = actions.toggle_selection,
---               loop_callback = actions.send_selected_to_qflist,
---             }
---             require("telescope").extensions.hop._hop_loop(prompt_bufnr, opts)
---           end,
---         },
---       },
---     },
---   },
--- </pre>
---@param prompt_bufnr number: The prompt bufnr
---@param opts table: options to pass to hop loop
---@field trace_entry boolean: entry hopped to will be highlighted via telescope selection hl groups (default: `false`)
---@field reset_selection boolean: return to entry selected before entering `hop` loop (default: `true`)
---@field escape_keys table: key chords that interrupt loop before `loop_callback` (default: `{"<ESC>", "<C-c>"`}`)
---@field accept_keys table: key chords that finish loop and execute `loop_callback if passed (default: `{"<CR>"}`)
---@field loop_callback function: `function(prompt_bufnr) ... end` ran post-loop (default: nil)
hop_actions._hop_loop = function(prompt_bufnr, opts)
  vim.validate {
    opts = { opts, "table", true },
  }
  opts = opts or {}
  local escape_keys = vim.tbl_map(function(key)
    return vim.api.nvim_replace_termcodes(key, true, false, true)
  end, vim.F.if_nil(
    opts.escape_keys,
    hop_config.escape_keys
  ))
  local accept_keys = vim.tbl_map(function(key)
    return vim.api.nvim_replace_termcodes(key, true, false, true)
  end, vim.F.if_nil(
    opts.accept_keys,
    hop_config.accept_keys
  ))

  local trace_entry = vim.F.if_nil(opts.trace_entry, hop_config.trace_entry)
  local clear_selection_hl = vim.F.if_nil(opts.clear_selection_hl, hop_config.clear_selection_hl)
  local reset_selection = vim.F.if_nil(opts.reset_selection, hop_config.reset_selection)

  vim.validate {
    trace_entry = {
      trace_entry,
      function()
        return not (clear_selection_hl and trace_entry)
      end,
      "Tracing entry is mutually exclusive with clearing selection",
    },
  }
  vim.validate {
    reset_selection = {
      reset_selection,
      function()
        return reset_selection or trace_entry
      end,
      "At least one of tracing or resetting selection must be set",
    },
  }
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  local row = current_picker:get_selection_row()

  while true do
    local key = hop_actions._hop(prompt_bufnr, opts)
    if vim.tbl_contains(accept_keys, key) then
      break
    end
    if vim.tbl_contains(escape_keys, key) then
      return
    end
    if not trace_entry then
      current_picker:set_selection(row)
    end
  end
  if reset_selection then
    current_picker:set_selection(row)
  end
  if opts.loop_callback ~= nil then
    opts.loop_callback(prompt_bufnr)
  end
  return
end

--- Iteratively toggle selection on hop char with default configuration until escape keys are registered.
hop_actions.hop_toggle_selection = function(prompt_bufnr)
  hop_actions._hop_loop(prompt_bufnr, { callback = actions.toggle_selection })
end

return hop_actions
