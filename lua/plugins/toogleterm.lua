return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		local toggleterm = require("toggleterm")
		toggleterm.setup({
			size = 15,
			open_mapping = [[<C-\>]],
			direction = "horizontal", -- can switch to "float"
			shade_terminals = true,
			start_in_insert = true,
			persist_size = true,
			close_on_exit = true,
			shell = vim.o.shell,
		})

		local Terminal = require("toggleterm.terminal").Terminal

		-- React Dev Server (Frontend)
		local react = Terminal:new({
			cmd = "npm start",
			dir = vim.fn.getcwd(),
			hidden = true,
			direction = "horizontal",
			count = 1,
		})

		-- Spring Boot App (Backend)
		local spring = Terminal:new({
			cmd = "./mvnw spring-boot:run",
			dir = vim.fn.getcwd(),
			hidden = true,
			direction = "horizontal",
			count = 2,
		})

		-- Keymaps
		vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Toggle Terminal" })
		vim.keymap.set("n", "<leader>tr", function()
			react:toggle()
		end, { desc = "Toggle React Dev Server" })
		vim.keymap.set("n", "<leader>ts", function()
			spring:toggle()
		end, { desc = "Toggle Spring Boot Server" })

		-- Optional: Kill both
		vim.keymap.set("n", "<leader>tk", function()
			react:shutdown()
			spring:shutdown()
		end, { desc = "Kill React & Spring Boot Terminals" })
	end,
}
