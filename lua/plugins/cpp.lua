return {
  {
    "Civitasv/cmake-tools.nvim",
    dependencies = { "stevearc/overseer.nvim" },
    lazy = true,
    init = function()
      --on initialization creates a list of all cmake commands
      local cmake_commands = {}

      local loaded = false -- flag determines whether currently loaded
      local active = false -- flag determines whether currently active

      --iterates through a table of all vim commands, matches them for CMake prefix and adds matching entries to cmake_commands table
      local get_commands = function()
        for cmd, _ in pairs(vim.api.nvim_get_commands({})) do
          if cmd:match("^CMake") then
            table.insert(cmake_commands, cmd)
          end
        end
      end

      --deactivats cmake tools by iterating through cmake_commands and deleting all commands that match
      local deactivate_cmake_tools = function()
        for _, cmd in ipairs(cmake_commands) do
          vim.api.nvim_del_user_command(cmd)
        end
        active = false
      end

      --activates cmake tools plugin
      local activate_cmake_tools = function()
        -- if the plugin is already loaded then reload.
        if loaded == true then
          require("lazy").reload({ plugins = { "cmake-tools.nvim" } })
        else -- else load the plugin and grab the cmake comamnds and set loaded flag
          require("lazy").load({ plugins = { "cmake-tools.nvim" } })
          get_commands()
          loaded = true
        end

        active = true
      end

      -- check runs on every single directory change. it is resposible for deciding when to show and when to hide cmake commands
      local function check()
        -- if in directory and inactive immediately return
        local in_dir = vim.fn.filereadable(vim.uv.cwd() .. "/CMakeLists.txt")
        if in_dir == 0 then
          if active == false then
            return --return early blocking clause
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
      cmake_command = "cmake", --cmake command to run in terminal
      cmake_build_directory = "build", --cmake build directory
      cmake_generate_options = { -- flags for build command, in this case callign for it to use ninja and export compile commands (needed for clangd integration)
        "-G",
        "Ninja",
        "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
      },
      cmake_build_options = {},
      cmake_root_markers = { "CMakeLists.txt", ".git" }, -- project roots, if it finds either its at the root

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
