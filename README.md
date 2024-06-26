- lua rewrite of [YankAssassin.vim](https://github.com/svban/YankAssassin.vim)

# What is YankAssassin.nvim?
It is really annoying when you want to yank text and the cursor moves to the start of the yanked text. Especially when you are using text-objects. This plugin helps you fix it. Basically, while Yanking your cursor will not move to the start of the Yanked Text.

## Demo
![1](https://user-images.githubusercontent.com/69670983/147871602-d5f1a6cb-97d4-4950-bb0f-ef7579b27852.gif)
![2](https://user-images.githubusercontent.com/69670983/147871603-813e3248-a093-4915-b209-cad5da276aca.gif)
![3](https://user-images.githubusercontent.com/69670983/147871606-bb17d8a6-53b2-4177-ac48-1c677f2f46c3.gif)

## Installation
- with Lazy.nvim
``` lua
    {
        "svban/YankAssassin.nvim",
        config = function()
            require("YankAssassin").setup {
                auto = true, -- if auto is true, autocmds are used. Whenever y is used anywhere, the cursor doesn't move to start
            }
            -- Optional Mappings
            vim.keymap.set({ "x", "n" }, "gy", "<Plug>(YADefault)", { silent = true })
            vim.keymap.set({ "x", "n" }, "<leader>y", "<Plug>(YANoMove)", { silent = true })
        end,
    },
```
- or install it, just like you would any other neovim-plugin.

## Features
1. Mapping-less solution - not necessary to set any mappings.
2. Text-objects, count, registers still work
3. Provides extra mappings, which have default behavior, and no move behavior
4. Works in both Normal & Visual Mode.


## Others
- If you are using Neovim, for Yank highlighting you can use
```
    augroup highlight_yank
        autocmd!
        au TextYankPost * silent! lua vim.highlight.on_yank{ higroup="IncSearch", timeout=500 }
    augroup END
```
- If you are using Vim, you can use
[svban/YankAssassin.vim](https://github.com/svban/YankAssassin.vim)
