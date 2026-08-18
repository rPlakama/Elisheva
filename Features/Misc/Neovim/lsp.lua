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

local function available_lsp_configs()
	local configs = {}
	for _, path in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
		local name = vim.fn.fnamemodify(path, ":t:r")
		if not configs[name] then
			local ok, cfg = pcall(vim.lsp.config[name])
			local cmd = ok and cfg and cfg.cmd
			local bin = type(cmd) == "table" and cmd[1] or nil

			if bin == nil or vim.fn.executable(bin) == 1 then
				configs[name] = true
			end
		end
	end
	return vim.tbl_keys(configs)
end

vim.lsp.enable(available_lsp_configs())
