return {
  "snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        pick = function(cmd, opts)
          return LazyVim.pick(cmd, opts)()
        end,
        --cat is not mine,  curtousy of felix lee, wanted to delete it from my ascii but not remove all credit
        header = [[
                    |\\      _,,,---,,_                                   
              ZZZzz /,`.-'`'    -.  ;-;;,_                                
                  |,4-  ) )-,_. ,\\ (  `'-'                               
                  '---''(_/--'  `-'\\_)                                   
       ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
       ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z    
       ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z       
       ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z         
       ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║           
       ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝           
 ]],
        -- stylua: ignore
        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = " ", key = "f", desc = "ファイル検索 ", action = ":lua Snacks.dashboard.pick('files')" },
         { icon = " ", key = "n", desc = "新規ファイル ", action = ":ene | startinsert" },
         { icon = " ", key = "g", desc = "テキスト検索 ", action = ":lua Snacks.dashboard.pick('live_grep')" },
         { icon = " ", key = "r", desc = "最近ファイル ", action = ":lua Snacks.dashboard.pick('oldfiles')" },
         { icon = " ", key = "c", desc = "設定", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
         { icon = " ", key = "s", desc = "セッション復元 ", section = "session" },
         { icon = " ", key = "x", desc = "レイジー拡張 ", action = ":LazyExtras" },
         { icon = "󰒲 ", key = "l", desc = "レイジー ", action = ":Lazy" },
         { icon = " ", key = "q", desc = "終了 ", action = ":qa" },
        },
      },
    },
  },
}
