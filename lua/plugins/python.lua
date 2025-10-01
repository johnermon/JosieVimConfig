--stores whether or not there is an existing python terminal
local python_term = nil

local function run_python(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr) -- gets the filename the buffer is currently pointing
  --if python term exists or job isnt currently waiting create new split for teminal
  if not python_term or vim.fn.jobwait({ python_term }, 0) ~= 1 then
    vim.cmd("10split | terminal")
    python_term = vim.b.terminal_job_id
    vim.api.nvim_buf_set_name(0, "Python Terminal")
  end
  --into that terminal send python3 (path to current buffer) running the file
  vim.fn.chansend(python_term, "python3 " .. vim.fn.fnameescape(file) .. "\n")
end

return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    --on attach of python language server create these usercommands
    opts.servers.pyright = {
      on_attach = function(_, bufnr)
        --creates new usercommand Python run that runs run_python function
        vim.api.nvim_create_user_command("PythonRun", function()
          run_python(bufnr)
        end, opts)

        --creates leader tied to current buffer that runs PythonRun
        vim.keymap.set("n", "<leader>cR", "<CMD>PythonRun<cr>", { desc = "Python Run", buffer = bufnr })
      end,
    }
  end,
}
