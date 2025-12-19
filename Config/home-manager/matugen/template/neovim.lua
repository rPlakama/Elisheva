return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '{{colors.background.default.hex}}',
				base01 = '{{colors.surface_container.default.hex}}',
				base02 = '{{colors.surface_container_highest.default.hex}}',
				base03 = '{{colors.outline_variant.default.hex}}',
				base04 = '{{colors.on_surface_variant.default.hex}}',
				base05 = '{{colors.on_surface.default.hex}}',
				base06 = '{{colors.on_surface.default.hex}}',
				base07 = '{{colors.inverse_on_surface.default.hex}}',

				base08 = '{{colors.error.default.hex}}',
				base09 = '{{colors.tertiary.default.hex}}',
				base0A = '{{colors.on_surface_variant.default.hex}}',
				base0B = '{{colors.primary.default.hex}}',
				base0C = '{{colors.secondary.default.hex}}',
				base0D = '{{colors.primary.default.hex}}',
				base0E = '{{colors.secondary.default.hex}}',
				base0F = '{{colors.error.default.hex}}',
			})

			local function set_hl_mutliple(groups, value)
				for _, v in pairs(groups) do
					vim.api.nvim_set_hl(0, v, value)
				end
			end
			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '{{colors.primary_container.default.hex}}',
				fg = '{{colors.on_primary_container.default.hex}}',
				bold = true
			})

			vim.api.nvim_set_hl(0, 'Search', {
				bg = '{{colors.tertiary_container.default.hex}}',
				fg = '{{colors.on_tertiary_container.default.hex}}'
			})
			vim.api.nvim_set_hl(0, 'CurSearch', {
				bg = '{{colors.tertiary.default.hex}}',
				fg = '{{colors.on_tertiary.default.hex}}'
			})

			set_hl_mutliple({ 'TSComment', 'Comment' }, {
				fg = '{{colors.outline.default.hex}}',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'LineNr', { fg = '{{colors.outline_variant.default.hex}}' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', {
				fg = '{{colors.primary.default.hex}}',
				bold = true
			})

			set_hl_mutliple({ 'TSMethod', 'Method' }, {
				fg = '{{colors.primary.default.hex}}',
			})

			set_hl_mutliple({ 'TSFunction', 'Function' }, {
				fg = '{{colors.primary.default.hex}}',
			})

			vim.api.nvim_set_hl(0, 'Keyword', {
				fg = '{{colors.secondary.default.hex}}',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', {
				fg = '{{colors.on_surface.default.hex}}',
			})
		end
	}
}
