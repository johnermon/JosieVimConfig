--lua language server is built in to lazyvim and as such in order to allow it to use hammerspoon
--functions in autocomplete i need to make sure that the lua server has hammerspoon globals and the source ecxensions
return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    local ls = opts.servers.lua_ls or {}
    ls.settings = vim.tbl_deep_extend("force", ls.settings or {}, {
      Lua = {
        diagnostics = {
          --adds hamerspoon global variable
          globals = { "hs" },
        },
        workspace = {
          library = {
            vim.fn.expand("~/.hammerspoon/Spoons/EmmyLua.spoon/annotations"),
          },
        },
      },
    })
    opts.servers.lua_ls = ls
  end,
}
