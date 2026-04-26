local tmp_dir = OwnUtil.sys.get_tmp_dir()
return {
  "CRAG666/code_runner.nvim",
  opts = {
    filetype = {
      javascript = "node",
      java = "cd $dir && javac $fileName && java $fileNameWithoutExt",
      kotlin = "cd $dir && kotlinc-native $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt.kexe",
      c = function()
        local c_base = {
          "cd $dir &&",
          "gcc $fileName -o",
          tmp_dir .. "/$fileNameWithoutExt",
        }
        local c_exec = {
          "&& " .. tmp_dir .. "/$fileNameWithoutExt &&",
          "rm " .. tmp_dir .. "/$fileNameWithoutExt",
        }
        vim.ui.input({ prompt = "Add more args:" }, function(input)
          c_base[4] = input
          vim.print(vim.tbl_extend("force", c_base, c_exec))
          require("code_runner.commands").run_from_fn(vim.list_extend(c_base, c_exec))
        end)
      end,
      cpp = {
        "cd $dir &&",
        "g++ $fileName",
        "-o " .. tmp_dir .. "/$fileNameWithoutExt &&",
        tmp_dir .. "/$fileNameWithoutExt",
      },
      python = "python -u '$dir/$fileName'",
      sh = "bash",
      typescript = "deno run",
      typescriptreact = "yarn dev$end",
      rust = "cd $dir && rustc $fileName && $dir$fileNameWithoutExt",
      dart = "dart",
      lua = "cd $dir && luajit $fileName",
    },
  },
  keys = {
    {
      "<leader>rc",
      function()
        require("code_runner").run_code()
      end,
      desc = "Execute Code",
    },
  },
}
