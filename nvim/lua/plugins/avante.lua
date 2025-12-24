local avante = {
  "yetone/avante.nvim",
  build = vim.fn.has("win32") ~= 0
      and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
  event = "VeryLazy",
  version = false,
  opts = {
    mode = "legacy",

    instructions_file = "avante.md",
    provider = "openrouter",
    providers = {
      openrouter = {
        __inherited_from = "openai",
        disable_tools = true,
        endpoint = "https://openrouter.ai/api/v1",
        model = "mistralai/devstral-2512:free",
        api_key_name = "OR_API_KEY",
        timeout = 30000,
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 20480,
        },
      },
    },

    mappings = {
    }
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          use_absolute_path = true,
        },
      },
    },
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}

return { avante }
