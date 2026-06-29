-- Blink
require("blink.cmp").setup({
	keymap = { preset = "default" },
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
})

vim.lsp.enable({
	"rust_analyzer",
	"tinymist",
	"ts_ls",
	"fish_lsp",
	"nil_ls",
	"nu",
	"lua_ls",
	"clangd",
	"kotlin_language_server"
})

vim.lsp.enable("ts_ls", {
	capabilities = capabilities,
	root_dir = vim.fs.root(0, { "tsconfig.json", "package.json", ".git" }),
	settings = {
		typescript = {
			format = {
				enable = true,
			},
		},
		javascript = {
			format = {
				enable = true,
			},
		},
	},
})

vim.lsp.enable("kotlin_language_server", {
	capabilities = capabilities,
	root_dir = vim.fs.root(0, { "build.gradle", "build.gradle.kts", ".git" }),
	settings = {
	},
})
