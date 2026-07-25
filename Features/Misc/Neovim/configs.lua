vim.opt.shortmess:append("I")
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.scrolloff = math.floor(vim.o.lines / 2) - 3

vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function()
		vim.cmd([[%s/\s\+$//e]])
		pcall(vim.lsp.buf.format, { async = false })
	end,
})

vim.api.nvim_create_autocmd("VimResized", {
	desc = "Automatically resize splits when the host window is resized",
	group = vim.api.nvim_create_augroup("resize_splits", { clear = true }),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})
