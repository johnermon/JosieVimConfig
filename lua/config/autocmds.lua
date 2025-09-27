-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- creates new jj keybind in all terminal windows except lazygit.
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if not bufname:match("lazygit") then
      vim.keymap.set("t", "jj", "<C-\\><C-n>", { buffer = args.buf })
    end
  end,
})
