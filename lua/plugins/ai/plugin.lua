local model = "qwen2.5-coder:1.5b"
return {
  {
    "olimorris/codecompanion.nvim",
    cmd = {
      "CodeCompanion",
      "CodeCompanionActions",
      "CodeCompanionCLI",
      "CodeCompanionChat",
      "CodeCompanionCmd",
      "CodeCompanionCodeReview",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      interactions = {
        chat = {
          adapter = {
            name = "ollama",
            model = model,
          },
        },
        inline = {
          adapter = {
            name = "ollama",
            model = model,
          },
        },
      },
      opts = {
        -- log_level = "DEBUG", -- or "TRACE"
      },
    },
  },

  {
    "milanglacier/minuet-ai.nvim",
    event = "BufReadPost",
    config = function()
      require("minuet").setup({
        provider = "openai_fim_compatible",

        n_completions = 1,
        context_window = 512,

        request_timeout = 30,
        throttle = 1000,
        debounce = 500,

        -- 开启详细调试通知
        -- notify = "debug",

        virtualtext = {
          -- 所有文件类型都允许自动触发
          auto_trigger_ft = OwnUtil.lang.treesitter,

          keymap = {
            accept = "<C-Down>",
            accept_line = "<C-Right>",
            accept_n_lines = "<A-z>",
            prev = "<A-[>",
            next = "<A-]>",
            dismiss = "<A-e>",
          },
        },

        provider_options = {
          openai_fim_compatible = {
            -- Ollama 本地接口只需要非空占位密钥
            api_key = function()
              return "ollama"
            end,

            name = "Ollama",
            end_point = "http://127.0.0.1:11434/v1/completions",
            model = "qwen2.5-coder:1.5b",

            optional = {
              max_tokens = 64,
              top_p = 0.9,
            },
          },
        },
      })
    end,
    keys = {
      {
        "<leader>ac",
        "<cmd>Minuet virtualtext toggle<cr>",
        desc = "[Minuet] toggle virtual text",
      },
    },
  },
}
