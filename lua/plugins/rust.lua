return {
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    ft = { "rust" },
    config = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(_, bufnr)
            local map = function(lhs, rhs, desc)
              vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
            end
            map("<leader>cR", "<cmd>RustLsp runnables<CR>", "Rust Run")
            map("<leader>cB", "<cmd>RustBuild<CR>", "Rust Build")
          end,
          settings = {
            ["rust-analyzer"] = {
              features = "all",
              cargo = { allFeatures = true },
              checkOnSave = { command = "clippy" },
            },
          },
        },
      }
    end,
  },
}
