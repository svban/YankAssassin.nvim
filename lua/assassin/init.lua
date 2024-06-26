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
	-- local operators = { "y"} -- Add more operators here if needed
	-- if vim.tbl_contains(operators, vim.v.event.operator) then
	vim.api.nvim_win_set_cursor(0, pre_yank_pos)
	-- end
end

local function setup_autocmds()
	vim.api.nvim_create_autocmd({ "VimEnter", "CursorMoved" }, {
		callback = function()
			pre_yank_motion()
		end,
	})
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			post_yank_motion()
		end,
	})
end

local function yank_operator(type)
	-- Determine the yank command based on the type
	local register = my_register == "" and '"' or my_register
	local yank_cmd = '"' .. register .. "y"
	local expr

	if type == "char" then
		expr = "`[v`]"
	elseif type == "line" then
		expr = "'[V']"
	elseif type == "block" then
		expr = "`[<C-v>`]"
	end

	vim.cmd("normal! " .. expr .. yank_cmd)
	-- Move cursor to the beginning of yanked text if auto is false
	if not auto then
		vim.cmd("normal! `[")
	end
end

-- Move the cursor to the start - default behavior
function M.default_yank_operator(type)
	-- Save current auto state
	local prev_auto = auto
	-- Disable auto behavior
	auto = false
	-- Yank based on the current mode and count
	yank_operator(type)
	-- Restore auto state
	auto = prev_auto
end

-- Do not move the cursor to the start
function M.special_yank_operator(type)
	-- Save current auto state
	local prev_auto = auto
	-- Enable auto behavior
	auto = false
	-- Yank based on the current mode and count
	yank_operator(type)
	post_yank_motion()
	-- Restore auto state
	auto = prev_auto
end

function M.setup(opts)
	opts = opts or {}
	auto = opts.auto or false

	if auto then
		setup_autocmds()
	end

	vim.keymap.set("n", "<Plug>(YADefault)", function()
		pre_yank_motion()
		vim.go.operatorfunc = "v:lua.require'assassin'.default_yank_operator"
		return "g@"
	end, { expr = true, noremap = true, silent = true })

	vim.keymap.set("x", "<Plug>(YADefault)", function()
		local prev_auto = auto
		auto = false
		vim.cmd("normal! " .. '"' .. vim.v.register .. "y")
		vim.cmd("normal! `[")
		auto = prev_auto
	end, { noremap = true, silent = true })

	vim.keymap.set("n", "<Plug>(YANoMove)", function()
		pre_yank_motion()
		vim.go.operatorfunc = "v:lua.require'assassin'.special_yank_operator"
		return "g@"
	end, { expr = true, noremap = true, silent = true })

	vim.keymap.set("x", "<Plug>(YANoMove)", function()
		local prev_auto = auto
		auto = false
		pre_yank_motion()
		vim.cmd("normal! " .. '"' .. vim.v.register .. "y")
		post_yank_motion()
		auto = prev_auto
	end, { noremap = true, silent = true })
end

return M
