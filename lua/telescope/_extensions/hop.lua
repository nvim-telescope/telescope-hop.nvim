---@brief [[
--- Telescope-hop.nvim is an extension for telescope.nvim. It helps you navigate, select,
--- and perform actions on results buffer with motions inspired by hop.nvim.
---
--- <pre>
--- To find out more:
--- https://github.com/nvim-telescope/telescope-hop.nvim
---
---   :h |telescope-hop.setup|
---   :h |telescope-hop.actions|
--- </pre>
---@brief ]]

---@tag telescope-hop.nvim

local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error "This extension requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)"
end

local hop_actions = require "telescope._extensions.hop.actions"
local hop_config = require "telescope._extensions.hop.config"

return telescope.register_extension {
  setup = hop_config.setup,
  exports = hop_actions,
}
