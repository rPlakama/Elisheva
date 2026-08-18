vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			format = {
				enable = true,
				defaultConfig = {
					indent_style = "space",
					indent_size = "2",
				},
			},
		},
	},
})

vim.lsp.config("ts_ls", {
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

-- server attaches per filetype.
local preferred = {
	lua = { "lua_ls" },
	nix = { "nixd", "nil_ls" },
	typst = { "tinymist" },
	markdown = { "marksman" },
	fish = { "fish_lsp" },
	python = { "basedpyright", "pyright", "ruff", "pylsp" },
	javascript = { "ts_ls", "denols", "biome" },
	javascriptreact = { "ts_ls", "denols", "biome" },
	typescript = { "ts_ls", "denols" },
	typescriptreact = { "ts_ls", "denols" },
	json = { "jsonls", "biome" },
	jsonc = { "jsonls", "biome" },
	c = { "clangd", "ccls" },
	cpp = { "clangd", "ccls" },
	rust = { "rust_analyzer" },
	go = { "gopls" },
}

local available = {}
for _, path in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
	local name = vim.fn.fnamemodify(path, ":t:r")
	if not available[name] then
		local ok, cfg = pcall(function()
			return vim.lsp.config[name]
		end)
		local cmd = ok and cfg and cfg.cmd
		local bin = type(cmd) == "table" and cmd[1] or nil
		if type(bin) == "string" and vim.fn.executable(bin) == 1 then
			available[name] = true
		end
	end
end

for _, ordered in pairs(preferred) do
	local winner
	for _, name in ipairs(ordered) do
		if available[name] then
			winner = name
			break
		end
	end
	if winner then
		for _, name in ipairs(ordered) do
			if name ~= winner then
				available[name] = nil
			end
		end
	end
end

vim.lsp.enable(vim.tbl_keys(available))
