for _, bind in ipairs({ "i", "a", "A" }) do
  vim.keymap.set("n", bind, function()
    if vim.fn.getline("."):match("^%s*$") then
      return [["_cc]]
    else
      return bind
    end
  end, { expr = true, noremap = true, silent = true })
end
