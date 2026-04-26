return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      -- 空文件夹折叠,缺点:在中间创建文件比较麻烦
      filesystem = {
        group_empty_dirs = true,
        scan_mode = "deep",
      },
    },
  },
}
