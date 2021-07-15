-- Setup telescope with defaults
if RELOAD then RELOAD('telescope') end
require('telescope').setup()

local docgen = require('docgen')

local docs = {}

docs.test = function()
  -- TODO: Fix the other files so that we can add them here.
  local input_files = {
    "./lua/telescope/_extensions/hop.lua",
    "./lua/telescope/_extensions/hop/config.lua",
    "./lua/telescope/_extensions/hop/actions.lua",
  }

  local output_file = "./doc/telescope-hop.txt"
  local output_file_handle = io.open(output_file, "w")

  for _, input_file in ipairs(input_files) do
    docgen.write(input_file, output_file_handle)
  end

  output_file_handle:write(" vim:tw=78:ts=8:ft=help:norl:\n")
  output_file_handle:close()
  vim.cmd [[checktime]]
end

docs.test()

return docs

