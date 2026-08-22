return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        neocmake = {
          cmd = { "neocmakelsp", "stdio" },
        },
      },
    },
  },
}
