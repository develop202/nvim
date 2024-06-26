local preview_cmd = "/bin/zathura --fork"
return {
  "CRAG666/code_runner.nvim",
  -- name = "code_runner",
  -- dev = true,
  config = function()
    require("code_runner").setup({
      v = "v run",
      tex = function(...)
        latexCompileOptions = {
          "Single",
          "Project",
        }
        local preview = require("code_runner.hooks.preview_pdf")
        local cr_au = require("code_runner.hooks.autocmd")
        vim.ui.select(latexCompileOptions, {
          prompt = "Select compile mode:",
        }, function(opt, _)
          if opt then
            if opt == "Single" then
              preview.run({
                command = "tectonic",
                args = { "$fileName", "--keep-logs", "-o", "/data/data/com.termux/files/usr/tmp" },
                preview_cmd = preview_cmd,
                overwrite_output = "/data/data/com.termux/files/usr/tmp",
              })
            elseif opt == "Project" then
              cr_au.stop_job()
              os.execute("tectonic -X build --keep-logs --open &> /dev/null &")
              local fn = function()
                os.execute("tectonic -X build --keep-logs &> /dev/null &")
              end
              cr_au.create_au_write(fn)
            end
          else
            local warn = require("utils").warn
            warn("Not Preview", "Preview")
          end
        end)
      end,
      markdown = function(...)
        markdownCompileOptions = {
          Normal = "pdf",
          Presentation = "beamer",
          Eisvogel = "",
          Slides = "",
        }
        local hook = require("code_runner.hooks.preview_pdf")
        vim.ui.select(vim.tbl_keys(markdownCompileOptions), {
          prompt = "Select preview mode:",
        }, function(opt, _)
          if opt then
            if opt == "Slides" then
              local filename = vim.fn.expand("%:p")
              os.execute("kitty slides " .. filename .. " &> /dev/null &")
            elseif opt == "Eisvogel" then
              hook.run({
                command = "bash",
                args = { "./build.sh" },
                preview_cmd = preview_cmd,
                overwrite_output = ".",
              })
            else
              hook.run({
                command = "pandoc",
                args = { "$fileName", "-o", "$tmpFile", "-t", markdownCompileOptions[opt] },
                preview_cmd = preview_cmd,
              })
            end
          else
            local warn = require("utils").warn
            warn("Not Preview", "Preview")
          end
        end)
      end,
      javascript = "node",
      java = "cd $dir && javac $fileName && java $fileNameWithoutExt",
      kotlin = "cd $dir && kotlinc-native $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt.kexe",
      c = {
        "cd $dir &&",
        "gcc $fileName -o",
        "/data/data/com.termux/files/usr/tmp/$fileNameWithoutExt &&",
        "/data/data/com.termux/files/usr/tmp/$fileNameWithoutExt &&",
        "rm /data/data/com.termux/files/usr/tmp/$fileNameWithoutExt",
      },
      cpp = {
        "cd $dir &&",
        "g++ $fileName",
        "-o /data/data/com.termux/files/usr/tmp/$fileNameWithoutExt &&",
        "/data/data/com.termux/files/usr/tmp/$fileNameWithoutExt",
      },
      python = "python -u '$dir/$fileName'",
      sh = "bash",
      typescript = "deno run",
      typescriptreact = "yarn dev$end",
      rust = "cd $dir && rustc $fileName && $dir$fileNameWithoutExt",
      dart = "dart",
      cs = function(...)
        local root_dir = require("null-ls.utils").root_pattern("*.csproj")(vim.loop.cwd())
        return "cd " .. root_dir .. " && dotnet run$end"
      end,
      lua = "cd $dir && luajit $fileName",
      project_path = vim.fn.expand("~/.config/nvim/project_manager.json"),
    })
  end,
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
