-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

--loads this configuration file if and only if the client running is neovide, changes the animation speed to make it less annoying
if vim.g.neovide then
  require("config.neovide")
end
