return {
	"mfussenegger/nvim-jdtls",
	ft = { "java" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"mfussenegger/nvim-dap",
		"rcarriga/nvim-dap-ui",
		"williamboman/mason.nvim",
	},
	config = function()
		local jdtls = require("jdtls")
		local home = os.getenv("HOME")
		local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
		local workspace_dir = home .. "/.local/share/eclipse/" .. project_name

		local jdtls_path = home .. "/.local/share/nvim/mason/packages/jdtls"
		local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
		local config_dir = jdtls_path .. "/config_linux"

		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		local config = {
			cmd = {
				"java",
				"-Declipse.application=org.eclipse.jdt.ls.core.id1",
				"-Dosgi.bundles.defaultStartLevel=4",
				"-Declipse.product=org.eclipse.jdt.ls.core.product",
				"-Dlog.protocol=true",
				"-Dlog.level=ALL",
				"-Xmx2g",
				"--add-modules=ALL-SYSTEM",
				"--add-opens",
				"java.base/java.util=ALL-UNNAMED",
				"--add-opens",
				"java.base/java.lang=ALL-UNNAMED",
				"-jar",
				launcher_jar,
				"-configuration",
				config_dir,
				"-data",
				workspace_dir,
			},

			root_dir = require("jdtls.setup").find_root({ "gradlew", "mvnw", ".git" }),
			capabilities = capabilities,

			settings = {
				java = {
					signatureHelp = { enabled = true },
					contentProvider = { preferred = "fernflower" },
					completion = {
						favoriteStaticMembers = {
							"org.junit.Assert.*",
							"org.junit.Assume.*",
							"org.junit.jupiter.api.Assertions.*",
							"org.mockito.Mockito.*",
							"org.mockito.ArgumentMatchers.*",
							"org.mockito.Answers.*",
						},
						filteredTypes = { "java.awt.*", "com.sun.*" },
					},
					sources = {
						organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
					},
					codeGeneration = {
						toString = { template = "${object.className}{${member.name()}=${member.value}, }" },
						useBlocks = true,
					},
				},
			},

			init_options = {
				bundles = {
					vim.fn.glob(
						home
							.. "/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
						true
					),
					vim.fn.glob(home .. "/.local/share/nvim/mason/packages/java-test/extension/server/*.jar", true),
				},
			},
		}

		-- 💡 Attach + IDE-like mappings
		config["on_attach"] = function(_, bufnr)
			local opts = { buffer = bufnr, noremap = true, silent = true }
			vim.keymap.set("n", "<leader>oi", jdtls.organize_imports, opts)
			vim.keymap.set("n", "<leader>ev", jdtls.extract_variable, opts)
			vim.keymap.set("n", "<leader>em", jdtls.extract_method, opts)
			vim.keymap.set("n", "<leader>r", jdtls.rename, opts)
			vim.keymap.set("n", "<F5>", function()
				require("dap").continue()
			end, opts)
			vim.keymap.set("n", "<F9>", function()
				require("dap").toggle_breakpoint()
			end, opts)
			vim.keymap.set("n", "<F10>", function()
				require("dap").step_over()
			end, opts)
			vim.keymap.set("n", "<F11>", function()
				require("dap").step_into()
			end, opts)
			vim.keymap.set("n", "<F12>", function()
				require("dap").step_out()
			end, opts)
			vim.keymap.set("n", "<leader>ft", function()
				vim.lsp.buf.format({ async = true })
			end, opts)
		end

		-- 🚀 DAP + test support
		require("jdtls").setup_dap({ hotcodereplace = "auto" })
		require("jdtls.dap").setup_dap_main_class_configs()

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "java",
			callback = function()
				jdtls.start_or_attach(config)
			end,
		})
	end,
}
