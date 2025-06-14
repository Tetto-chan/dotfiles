" Установка leader key
let mapleader=" " 

" Инициализация vim-plug для управления плагинами
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

" Подключение плагинов
call plug#begin('/home/tetto/.local/share/nvim/site/autoload')

" Плагины для улучшения работы с Java
Plug 'simaxme/java.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'mfussenegger/nvim-jdtls'

" Плагины для отладки
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'nvim-neotest/nvim-nio'

" Поддержка LSP и улучшения для интерфейса
Plug 'glepnir/lspsaga.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'kevinhwang91/nvim-hlslens'

" Разное
Plug 'akinsho/toggleterm.nvim'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvimdev/dashboard-nvim'
Plug 'edluffy/hologram.nvim'
Plug 'wakatime/vim-wakatime'
Plug 'navarasu/onedark.nvim'
Plug 'glepnir/galaxyline.nvim' , { 'branch': 'main' }
Plug 'ryanoasis/vim-devicons'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
Plug 'tpope/vim-fugitive'
Plug 'folke/trouble.nvim'

call plug#end()

" ==========================
" Настройки для каждого плагина
" ==========================

lua << EOF
require('hlslens').setup()
EOF


" ---------------------------
" Настройка LSP для Java
" ---------------------------
function! SetupJdtls()
    let l:config = {
    \   'cmd': ['/usr/bin/jdtls'],
    \   'root_dir': getcwd(),
    \   'settings': {
    \     'java': {
    \       'signatureHelp': { 'enabled': v:true },
    \       'contentProvider': { 'preferred': 'fernflower' },
    \     },
    \   },
    \   'init_options': {
    \     'bundles': []
    \   },
    \ }
    lua require('jdtls').start_or_attach(v:config)
endfunction

autocmd FileType java call SetupJdtls()

" ---------------------------
" Настройка Treesitter
" ---------------------------
" Установка и настройка nvim-treesitter
lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = {"java", "lua", "vim", "python"},  " Список языков, для которых нужно установить парсеры
  highlight = {
    enable = true,              " Включает подсветку
    additional_vim_regex_highlighting = false,
  },
}
EOF


" ---------------------------
" Настройка lspsaga (улучшенные интерфейсы LSP)
" ---------------------------
lua << EOF
require'lspsaga'.setup {}
EOF

" ---------------------------
" Настройки для nvim-hlslens
" ---------------------------
lua << EOF
require('hlslens').setup()
EOF

" ---------------------------
" Настройки для Trouble (отладка и навигация по ошибкам)
" ---------------------------
lua << EOF
require('trouble').setup {}
require'lspconfig'.jdtls.setup{}
EOF

" ---------------------------
" Настройка для Galaxyline (строка состояния)
" ---------------------------
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

" ---------------------------
" Настройка цветовой схемы onedark
" ---------------------------
lua << EOF
require('onedark').setup {
    style = 'deep',
    transparent = false,
    term_colors = true,
    ending_tildes = false,
    cmp_itemkind_reverse = false,

    code_style = {
        comments = 'italic',
        keywords = 'bold',
        functions = 'italic',
        strings = 'none',
        variables = 'none'
    },

    diagnostics = {
        darker = true,
        undercurl = true,
        background = true,
    },
}
require('onedark').load()
EOF

" ---------------------------
" Настройка для nvim-tree
" ---------------------------
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

" ---------------------------
" Настройка для Toggleterm (терминал)
" ---------------------------
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

" ---------------------------
" Настройка для hologram.nvim (отображение изображений)
" ---------------------------
lua << EOF
require('hologram').setup{
  auto_display = true
}
EOF

" ---------------------------
" Настройка для DAP UI (интерфейс для отладки)
" ---------------------------
lua << EOF
require('dapui').setup()
EOF

" ---------------------------
" Настройки для Telescope (поиск)
" ---------------------------
lua << EOF
require('telescope').setup{
  defaults = {},
  pickers = {},
  extensions = {}
}
EOF

let g:clipboard = {
    \ 'name': 'wl-clipboard',
    \ 'copy': { '+': 'wl-copy', '*': 'wl-copy' },
    \ 'paste': { '+': 'wl-paste', '*': 'wl-paste' },
    \ 'cache_enabled': 0,
    \ }


" ==========================
" Настройки ключевых маппингов
" ==========================

" Маппинги для работы с файлом
nnoremap <leader>e :NvimTreeToggle<CR>
nnoremap <leader>ff <cmd>Telescope find_files<CR>
nnoremap <leader>fg <cmd>Telescope live_grep<CR>
nnoremap <leader>fb <cmd>Telescope buffers<CR>
nnoremap <leader>fh <cmd>Telescope help_tags<CR>

" Маппинги для работы с LSP
nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <leader>rn <cmd>lua vim.lsp.buf.rename()<CR>

" Базовые настройки редактора
syntax on                " Включить подсветку синтаксиса
set encoding=utf-8        " Кодировка UTF-8
set expandtab             " Преобразование табов в пробелы
set shiftwidth=4          " Ширина отступов
set softtabstop=4         " Размер табов при редактировании
set tabstop=4             " Отображаемый размер табов
set number                " Включить нумерацию строк
set termguicolors         " Включить поддержку 24-битных цветов в терминале
set clipboard=unnamedplus " Использовать системный буфер обмена

" Маппинг для копирования в системный буфер обмена с помощью Ctrl + y
nnoremap <C-c> "+y
vnoremap <C-c> "+y

" Дополнительные маппинги
vmap cc :norm i#<CR>      " Добавить комментарий ко всей выделенной строке
vmap uc :norm ^x<CR>      " Убрать комментарий
vmap tb :norm i" '<CR>    " Вставить кавычки вокруг текста
nnoremap <C-g> :RenameCurrentFile<CR> " Быстрое переименование файла

" ==========================
" Настройки маппингов для гит
" ==========================

" Открыть Git статус (аналог команды git status)
nmap <leader>gs :Git<CR>

" Добавить файл в индекс (аналог git add)
nmap <leader>ga :Git add %<CR>

" Коммит изменений (аналог git commit)
nmap <leader>gc :Git commit<CR>

" Запушить изменения (аналог git push)
nmap <leader>gp :Git push<CR>

" Запуллить изменения (аналог git pull)
nmap <leader>gl :Git pull<CR>

" Просмотр диффов для текущего файла
nmap <leader>gd :Gdiffsplit<CR>

" Быстрый доступ к истории коммитов (аналог git log)
nmap <leader>gh :Git log<CR>

" Просмотр блэйма для текущего файла
nmap <leader>gb :Git blame<CR>

" Просмотр веток
nmap <leader>gB :Git branch<CR>

nmap <leader>ga :Git add %<CR>

" Восстановление изменений (аналог git checkout -- <file>)
nmap <leader>gr :Git checkout -- %<CR>

