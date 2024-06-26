local M = {}

local auto = false
local pre_yank_pos = {}
local my_register = ""

-- Function to save the cursor position before yanking
local function pre_yank_motion()
	pre_yank_pos = vim.api.nvim_win_get_cursor(0)
	my_register = vim.v.register == "" and '"' or vim.v.register
end

-- Function to restore the cursor position after yanking
local function post_yank_motion()
	vim.api.nvim_win_set_cursor(0, pre_yank_pos)
end

-- Sets up autocmds for auto=true
local function setup_autocmds()
	vim.api.nvim_create_autocmd({ "VimEnter", "CursorMoved" }, {
		callback = function()
			pre_yank_motion()
		end,
	})
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			-- Only restore position after yanked with 'y' operator only
			-- If not set, text yanked with c will also activate it
			local operators = { "y" } -- Add more operators here if needed
			if vim.tbl_contains(operators, vim.v.event.operator) then
				vim.api.nvim_win_set_cursor(0, pre_yank_pos)
			end
		end,
	})
end

-- Copy of vim's default yank operator
local function yank_operator(type)
	local register = my_register == "" and '"' or my_register
	local expr

	-- Determine the yank command based on the type
	if type == "char" then
		expr = "`[v`]"
	elseif type == "line" then
		expr = "'[V']"
	elseif type == "block" then
		expr = "`[<C-v>`]"
	end

	vim.cmd("normal! " .. expr .. '"' .. register .. "y")
end

-- Move the cursor to the start - default behavior
function M.default_yank_operator(type)
	auto = false
	yank_operator(type)
	vim.cmd("normal! `[")
end

-- Do not move the cursor to the start
function M.special_yank_operator(type)
	auto = false
	yank_operator(type)
	post_yank_motion()
end

function M.setup(opts)
	opts = opts or {}
	auto = opts.auto or false

	if auto == true then
		setup_autocmds()
	end

	vim.keymap.set("n", "<Plug>(YADefault)", function()
		pre_yank_motion()
		vim.go.operatorfunc = "v:lua.require'YankAssassin'.default_yank_operator"
		return "g@"
	end, { expr = true, noremap = true, silent = true })

	vim.keymap.set({ "x", "v" }, "<Plug>(YADefault)", function()
		vim.cmd("normal! " .. '"' .. vim.v.register .. "y")
		vim.cmd("normal! `[")
	end, { noremap = true, silent = true })

	vim.keymap.set("n", "<Plug>(YANoMove)", function()
		pre_yank_motion()
		vim.go.operatorfunc = "v:lua.require'YankAssassin'.special_yank_operator"
		return "g@"
	end, { expr = true, noremap = true, silent = true })

	vim.keymap.set({ "x", "v" }, "<Plug>(YANoMove)", function()
		pre_yank_motion()
		vim.cmd("normal! " .. '"' .. vim.v.register .. "y")
		post_yank_motion()
	end, { noremap = true, silent = true })
end

return M
