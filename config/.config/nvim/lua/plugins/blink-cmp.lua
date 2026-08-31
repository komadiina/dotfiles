return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "default",
      ["<CR>"] = {}, -- remove enter from accepting completions
      ["<C-CR>"] = { "accept", "fallback" }, -- use ctrl+enter instead
    },
  },
}
