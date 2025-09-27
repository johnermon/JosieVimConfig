return {
  {
    "Civitasv/cmake-tools.nvim",
    dependencies = { "stevearc/overseer.nvim" },
    lazy = true,
    init = function()
      local loaded = false
      local function check()
        local cwd = vim.uv.cwd()
        if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
          require("lazy").load({ plugins = { "cmake-tools.nvim" } })
          loaded = true
        end
      end
      check()
      vim.api.nvim_create_autocmd("DirChanged", {
        callback = function()
          if not loaded then
            check()
          end
        end,
      })
    end,
    opts = {
      cmake_command = "cmake",
      cmake_build_directory = "build",
      cmake_generate_options = { "-G", "Ninja" },
      cmake_build_options = {},
      cmake_root_markers = { "CMakeLists.txt", ".git" },

      cmake_settings = {
        {
          name = "Debug",
          generator = "Ninja",
          buildDirectory = "build/Debug",
          configurationType = "Debug",
        },
        {
          name = "Release",
          generator = "Ninja",
          buildDirectory = "build/Release",
          configurationType = "Release",
        },
      },

      cmake_target_settings = {
        myapp = {
          args = { "--verbose" },
          working_dir = "${dir.source}",
          env = {
            MY_ENV = "1",
          },
        },
      },
    },
  },
  --sets the creation of Cmake Commands to be only on attach of cmake server
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.clangd = {
        on_attach = function(_, bufnr)
          --keybinds for the cmake commands
          vim.keymap.set("n", "<leader>cR", "<cmd>CMakeRun<CR>", { desc = "Cmake Run", buffer = bufnr })
          vim.keymap.set("n", "<leader>cG", "<cmd>CMakeGenerate<CR>", { desc = "Cmake Generate", buffer = bufnr })
          vim.keymap.set("n", "<leader>cG", "<cmd>CMakeBuild<CR>", { desc = "Cmake Build", buffer = bufnr })
        end,
      }
    end,
  },
}
