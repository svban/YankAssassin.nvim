local M = {}

local auto = false

local function setup_autocmds()
	local pre_yank_pos = {}

	-- Function to save the cursor position before yanking
	local function pre_yank_motion()
		pre_yank_pos = vim.api.nvim_win_get_cursor(0)
	end

	-- Function to restore the cursor position after yanking
	local function post_yank_motion()
		local operators = { "y" } -- Add more operators here if needed
		if vim.tbl_contains(operators, vim.v.event.operator) then
			vim.api.nvim_win_set_cursor(0, pre_yank_pos)
		end
	end

	vim.api.nvim_create_autocmd({ "VimEnter", "CursorMoved" }, {
		callback = function()
			if auto then
				pre_yank_motion()
			end
		end,
	})
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			if auto then
				post_yank_motion()
			end
		end,
	})
end

function M.my_pre_yank_motion() end

-- Move the cursor to the start - default behavior
function M.default_yank_operator()
	-- Save current auto state
	local prev_auto = auto
	-- Disable auto behavior
	auto = false
	vim.cmd("keepjumps normal!" .. "gv" .. '"' .. vim.v.register .. "y")
	-- Move cursor to the beginning of yanked text
	vim.cmd("normal! `[")
	-- Restore auto state
	auto = prev_auto
end

-- Do not move the cursor to the start
function M.special_yank_operator()
	-- Save current auto state
	local prev_auto = auto
	-- Disable auto behavior
	auto = true
	local reg = vim.v.register
	vim.cmd('normal! gv"' .. reg .. "y")
	-- Restore auto state
	auto = prev_auto
end

function M.setup(opts)
	opts = opts or {}
	auto = opts.auto or false

	setup_autocmds()

	vim.keymap.set(
		"n",
		"<Plug>(YADefault)",
		":set operatorfunc=v:lua.require'assassin'.default_yank_operator<CR>g@",
		{ noremap = true, silent = true }
	)
	vim.keymap.set(
		{ "x", "v" },
		"<Plug>(YADefault)",
		":<C-U>call v:lua.require'assassin'.default_yank_operator()<CR>",
		{ noremap = true, silent = true }
	)

	vim.keymap.set(
		"n",
		"<Plug>(YAMove)",
		":set operatorfunc=v:lua.require'assassin'.special_yank_operator<CR>g@",
		{ noremap = true, silent = true }
	)
	vim.keymap.set(
		{ "x", "v" },
		"<Plug>(YAMove)",
		":<C-U>call v:lua.require'assassin'.special_yank_operator()<CR>",
		{ noremap = true, silent = true }
	)
end

return M
