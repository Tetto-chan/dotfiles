let mapleader=" " 

" Инициализация vim-plug
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif
call plug#begin('/home/tetto/.local/share/nvim/site/autoload')
Plug 'kevinhwang91/nvim-hlslens'
Plug 'simaxme/java.nvim'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvimdev/dashboard-nvim'
Plug 'edluffy/hologram.nvim'
Plug 'akinsho/toggleterm.nvim'
Plug 'mfussenegger/nvim-dap'
Plug 'nvim-neotest/nvim-nio'
Plug 'rcarriga/nvim-dap-ui'
Plug 'wakatime/vim-wakatime'
Plug 'navarasu/onedark.nvim'
Plug 'glepnir/galaxyline.nvim' , { 'branch': 'main' }
Plug 'ryanoasis/vim-devicons'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
" or                                , { 'branch': '0.1.x' }
call plug#end()

" Настройки для каждого плагина

" Настройки для galaxyline
lua << EOF
local gl = require('galaxyline')
local colors = require('galaxyline.themes.colors').default
local condition = require('galaxyline.condition')
local gls = gl.section

gl.short_line_list = {'NvimTree','vista','dbui','packer'}

gls.left[1] = {
  ViMode = {
    provider = function()
      local alias = {
        n = 'NORMAL',
        i = 'INSERT',
        c = 'COMMAND',
        V = 'VISUAL',
        ['␖'] = 'V-BLOCK',
        v = 'VISUAL',
        R = 'REPLACE',
      }
      local mode_color = {
        n = colors.blue,
        i = colors.green,
        v = colors.orange,
        ['␖'] = colors.blue,
        V = colors.blue,
        c = colors.magenta,
        no = colors.red,
        s = colors.orange,
        S = colors.orange,
        ['␓'] = colors.orange,
        ic = colors.yellow,
        R = colors.red,
        Rv = colors.red,
        cv = colors.red,
        ce = colors.red,
        r = colors.cyan,
        rm = colors.cyan,
        ['r?'] = colors.cyan,
        ['!'] = colors.red,
        t = colors.red
      }
      vim.api.nvim_command('hi GalaxyViMode guifg='..mode_color[vim.fn.mode()])
      return alias[vim.fn.mode()] .. ' '
    end,
    highlight = {colors.red,colors.bg,'bold'},
  },
}
EOF

" Установка цветовой схемы onedark
lua << EOF
require('onedark').setup {
    style = 'deep', -- Доступные стили: 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'
    transparent = false,
    term_colors = true,
    ending_tildes = false,
    cmp_itemkind_reverse = false,

    -- изменить стили
    code_style = {
        comments = 'italic',
        keywords = 'bold',
        functions = 'italic',
        strings = 'none',
        variables = 'none'
    },

    -- луа-модули
    diagnostics = {
        darker = true,
        undercurl = true,
        background = true,
    },
}
require('onedark').load()
EOF

" Применение цветовой схемы
colorscheme onedark

" Настройки для nvim-hlslens
lua << EOF
require('hlslens').setup()
EOF

" Настройки для telescope
lua << EOF
require('telescope').setup{
  defaults = {
    -- Настройки по умолчанию
  },
  pickers = {
    -- Настройки для встроенных пикеров
  },
  extensions = {
    -- Настройки для расширений
  }
}
EOF

" Настройки для dashboard-nvim
lua << EOF
require('dashboard').setup()
EOF

" Настройки для hologram.nvim
lua << EOF
require('hologram').setup{
  auto_display = true -- Automatically display images
}
EOF

lua << EOF
require('toggleterm').setup{
    size = 20,
    open_mapping = [[<c-\>]],
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = 'horizontal',
}
EOF

lua << EOF
require('dapui').setup()
EOF

lua << EOF
require'nvim-tree'.setup {
  view = {
    width = 30,
    side = 'left',
  },
  renderer = {
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
      glyphs = {
        default = '',
        symlink = '',
        folder = {
          arrow_open = '',
          arrow_closed = '',
          default = '',
          open = '',
          empty = '',
          empty_open = '',
          symlink = '',
          symlink_open = '',
        },
        git = {
          unstaged = "✗",
          staged = "✓",
          unmerged = "",
          renamed = "➜",
          untracked = "★",
          deleted = "",
          ignored = "◌",
        },
      },
    },
  },
  filters = {
    dotfiles = false,
    custom = {'.git', 'node_modules', '.cache'}
  }
}
EOF

" Маппинг для открытия nvim-tree
nnoremap <leader>ff <cmd>Telescope find_files<CR>
nnoremap <leader>fg <cmd>Telescope live_grep<CR>
nnoremap <leader>fb <cmd>Telescope buffers<CR>
nnoremap <leader>fh <cmd>Telescope help_tags<CR>
nnoremap <leader>e :NvimTreeToggle<CR>
nnoremap n <cmd>execute('normal! ' . v:count1 . 'n')<CR><cmd>lua require('hlslens').start()<CR>
nnoremap N <cmd>execute('normal! ' . v:count1 . 'N')<CR><cmd>lua require('hlslens').start()<CR>

" Отладка
nnoremap <leader>d :lua require('dapui').toggle()<CR>

" Dashboard
nnoremap <leader>db :Dashboard<CR>
nnoremap <leader>dn :DashboardNewFile<CR>

" ToggleTerm
nnoremap <leader>t :ToggleTerm<CR>

" Настройка строки состояния
set laststatus=2 " Всегда отображать строку состояния
set statusline=%f%m%r%h%w\ [%{&ff}]\ [%{&fileencoding}]\ [%{&fileformat}]\ [%{&filetype}]\ [%c]\ [%l/%L]\ [%p%%]

set encoding=utf-8
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set number
set termguicolors
set clipboard=unnamedplus

