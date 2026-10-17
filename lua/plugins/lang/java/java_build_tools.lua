return {
  {
    "oclay1st/maven.nvim",
    cmd = { "Maven", "MavenInit", "MavenExec", "MavenFavorites" },
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {}, -- options, see default configuration
    keys = {
      { "<leader>M", desc = "+Maven", mode = { "n", "v" } },
      { "<leader>Mm", "<cmd>Maven<cr>", desc = "Maven Projects" },
      { "<leader>Mf", "<cmd>MavenFavorites<cr>", desc = "Maven Favorite Commands" },
    },
  },
  {
    "pandalec/gradle.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "akinsho/toggleterm.nvim",
    },
    opts = {},
    keys = {
      { "<leader>rg", desc = "+Gradle", mode = { "n" } },
      {
        "<leader>rgt",
        function()
          require("gradle").tasks.refresh_tasks_async()
        end,
        desc = "Refresh Gradle tasks asynchronously",
      },
      {
        "<leader>rgp",
        function()
          require("gradle").telescope.pick_tasks()
        end,
        desc = "Pick and run a Gradle task via Telescope",
      },
      {
        "<leader>rgT",
        function()
          require("gradle").terminal.toggle()
        end,
        desc = "Toggle the Gradle floating terminal",
      },
    },
  },
}
