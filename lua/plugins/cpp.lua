return {
  {
    "Civitasv/cmake-tools.nvim",
    dependencies = { "stevearc/overseer.nvim" },
    lazy = true,
    init = function()
      --on initialization creates a list of all cmake commands
      local cmake_commands = {}

      --initializes loaded variable as false, and hs a function checks current directory for cmakelists and walks backwards
      local loaded = false
      local active = false

      local get_commands = function()
        for cmd, _ in pairs(vim.api.nvim_get_commands({})) do
          if cmd:match("^CMake") then
            table.insert(cmake_commands, cmd)
          end
        end
      end

      local deactivate_cmake_tools = function()
        for _, cmd in ipairs(cmake_commands) do
          vim.api.nvim_del_user_command(cmd)
        end
        active = false
      end

      -- function activates cmake tools by checking if its loaded. if it is not loaded loads it.
      local activate_cmake_tools = function()
        if loaded == false then
          require("lazy").load({ plugins = { "cmake-tools.nvim" } })
          get_commands()
          loaded = true
        elseif active ~= true then --if inactive and loaded
          require("lazy").reload({ plugins = { "cmake-tools.nvim" } })
        end
        active = true
      end

      local function check()
        -- if in directory and inactive immediately return
        local in_dir = vim.fn.filereadable(vim.uv.cwd() .. "/CMakeLists.txt")
        if in_dir == 0 then
          if active == false then
            return
          end

          -- if active then deactivate then return
          deactivate_cmake_tools()
          return
        end

        --if inactive and in dir then activate
        if active == false then
          activate_cmake_tools()
        end
      end

      -- runs the check command then creates an autocmd on dir change that reruns it
      check()
      vim.api.nvim_create_autocmd("DirChanged", {
        callback = function()
          check()
        end,
      })
    end,

    --cmake tools configuration
    opts = {
      cmake_command = "cmake",
      cmake_build_directory = "build",
      cmake_generate_options = {
        "-G",
        "Ninja",
        "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
      },
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
          vim.keymap.set("n", "<leader>cB", "<cmd>CMakeBuild<CR>", { desc = "Cmake Build", buffer = bufnr })
          vim.keymap.set("n", "<leader>cG", "<cmd>CMakeGenerate<CR>", { desc = "Cmake Generate", buffer = bufnr })
        end,
      }

      --only exposes cmakegenerate on cmake server attached
      opts.servers.cmake = {
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "<leader>cG", "<cmd>CMakeGenerate<CR>", { desc = "Cmake Generate", buffer = bufnr })
        end,
      }
    end,
  },
}
