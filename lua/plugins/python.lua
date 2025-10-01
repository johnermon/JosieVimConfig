local path = require("plenary.path")
--stores whether or not there is an existing python terminal
local terminal_instance = {
  terminal_job = nil,
  term_buf = 0,
  term_working_dir = vim.loop.cwd(),
}

local function terminal_visible(bufnr)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      return true
    end
  end
  return false
end

local function find_python_root(bufnr)
  bufnr = bufnr or 0 --if a buffer is not specified then default to buffer zero
  local file = vim.api.nvim_buf_get_name(bufnr) -- gets the filename the buffer is currently pointing to

  --returns current working directory if buffer is blank
  if file == "" then
    vim.notify("working directory buffer is blank")
    return
  end

  --creates new plenary path from the nvim buffer directory
  local dir = path:new(file)
  while dir.filename ~= dir:parent().filename do
    --if cmakelists exists in current path return
    if dir:joinpath("__main__.py"):exists() then
      terminal_instance.term_working_dir = dir
    end

    --sets dir to parent dir
    dir = dir:parent()
  end
end

local function run_python(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr) -- gets the filename the buffer is currently pointing

  --checks for valid python file extension
  -- if string.sub(file, -3) ~= ".py" then
  --   vim.notify("Not a valid Python file")
  --   return
  -- end

  --if python term exists or job isnt currently waiting create new split for teminal
  if not terminal_instance.terminal_job or vim.fn.jobwait({ terminal_instance.terminal_job }, 0)[1] ~= -1 then
    vim.cmd("10split")
    vim.cmd("terminal")
    vim.api.nvim_buf_set_name(0, "Python Terminal")
    terminal_instance.terminal_job = vim.b.terminal_job_id
    terminal_instance.term_buf = vim.api.nvim_get_current_buf()
  end

  --if terninal is not visable recreate split and attach terminal there
  if not terminal_visible(terminal_instance.term_buf) then
    vim.cmd("10split")
    vim.api.nvim_set_current_buf(terminal_instance.term_buf)
  end

  --finds the project root
  find_python_root(bufnr)

  --finds the basename and the project name to properly run python project
  local cwd = vim.fs.normalize(terminal_instance.term_working_dir:parent().filename)
  local project_name = vim.fs.basename(vim.fs.normalize(terminal_instance.term_working_dir.filename))

  --into that terminal send python3 (path to current buffer) running the file
  vim.fn.chansend(terminal_instance.terminal_job, "cd " .. cwd .. "\n")
  vim.fn.chansend(terminal_instance.terminal_job, "python3 -m" .. project_name .. "\n")
  vim.cmd("normal! G")
end

return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    --on attach of python language server create these usercommands
    opts.servers.pyright = {
      on_attach = function(_, bufnr)
        --creates new usercommand Python run that runs run_python function
        vim.api.nvim_create_user_command("PythonRun", function()
          local win = vim.api.nvim_get_current_win() -- gets current window
          run_python(bufnr)
          vim.api.nvim_set_current_win(win) -- sets window to the original window
        end, {})

        --creates leader tied to current buffer that runs PythonRun
        vim.keymap.set("n", "<leader>cR", "<CMD>PythonRun<cr>", { desc = "Python Run", buffer = bufnr })
      end,
    }
  end,
}
