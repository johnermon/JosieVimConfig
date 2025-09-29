local path = require("plenary.path")

--function gets the directory of the currently loaded buffer and walks down directory until it finds CMakeLists
local function find_cmake_root(bufnr)
  bufnr = bufnr or 0 --if a buffer is not specified then default to buffer zero
  local file = vim.api.nvim_buf_get_name(bufnr) -- gets the filename the buffer is currently pointing to

  --returns current working directory if buffer is blank
  if file == "" then
    return vim.loop.cwd()
  end

  --creates new plenary path from the nvim buffer directory
  local dir = path:new(file)
  while dir.filename ~= dir:parent().filename do
    --if cmakelists exists in current path return
    if dir:joinpath("CMakeLists.txt"):exists() then
      return dir.filename
    end

    --sets dir to parent dir
    dir = dir:parent()
  end

  -- returns as a fallback
  return vim.loop.cwd()
end

local function cmake_smart_cwd()
  local curr_buffer = find_cmake_root()
  require("cmake-tools").select_cwd({ args = curr_buffer }) -- undocumented cmake tools function, changes cwd of cmaketools
end

local loaded = false
local try_load = function()
  if loaded == false then
    require("lazy").load({ plugins = { "cmake-tools.nvim" } })

    vim.api.nvim_create_user_command("CmakeSmartCwd", function()
      cmake_smart_cwd()
    end, {})

    loaded = true
    require("cmake-tools").setup({
      cmake_command = "cmake", --cmake command to run in terminal
      cmake_build_directory = "build", --cmake build directory
      cmake_generate_options = { -- flags for build command, in this case callign for it to use ninja and export compile commands (needed for clangd integration)
        "-G Ninja",
        "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
      },
      cmake_root_markers = { "CMakeLists.txt" }, -- project roots, if it finds either its at the root
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
    })
  end
end

return {
  {
    "Civitasv/cmake-tools.nvim",
    dependencies = { "stevearc/overseer.nvim" },
    lazy = true,
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.clangd = {
        on_attach = function(_, bufnr)
          try_load()
          cmake_smart_cwd()
          --keybinds for the cmake commands
          vim.keymap.set("n", "<leader>cR", "<cmd>CMakeRun<CR>", { desc = "Cmake Run", buffer = bufnr })
          vim.keymap.set("n", "<leader>cB", "<cmd>CMakeBuild<CR>", { desc = "Cmake Build", buffer = bufnr })
          vim.keymap.set("n", "<leader>cG", "<cmd>CMakeGenerate<CR>", { desc = "Cmake Generate", buffer = bufnr })
        end,
      }

      --only exposes cmakegenerate on cmake server attached
      opts.servers.cmake = {
        on_attach = function(_, bufnr)
          try_load()
          cmake_smart_cwd()
          vim.keymap.set("n", "<leader>cG", "<cmd>CMakeGenerate<CR>", { desc = "Cmake Generate", buffer = bufnr })
        end,
      }
    end,
  },
}
