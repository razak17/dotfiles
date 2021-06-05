local vim = vim

-- require('internal.folds')

local function set(key, value)
  vim.opt[key] = value
end

-- Disable to improve startup time
-- vim.cmd [[
--   syntax off
--   filetype plugin indent off
--   filetype off
--   set nospell
-- ]]

vim.cmd('set iskeyword+=-')
vim.o.formatoptions = "cro"
vim.go.t_Co = "256"
vim.g.vimsyn_embed = "lPr" -- allow embedded syntax highlighting for lua,python and ruby

-- Neovim Directories
local cache_dir = vim.fn.stdpath('cache') .. '/'
set('udir', cache_dir .. 'undodir')
set('directory', cache_dir .. 'swap')
set('backupdir', cache_dir .. 'backup')
set('viewdir', cache_dir .. 'view')
set('backupskip',
    '/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim')

-- Timing
set('timeout', true)
set('ttimeout', true)
set('timeoutlen', 500)
set('ttimeoutlen', 10)
set('updatetime', 100)
set('redrawtime', 1500)

-- Folds
set('foldmethod', 'expr')
set('foldenable', true)
set('foldlevelstart', 10)
-- set('foldtext', "v:lua.folds()")

-- Tabs and Indents
set('breakindentopt', 'shift:2,min:20')
set('cindent', true) -- Increase indent on line after opening brace
set('smarttab', true) -- Tab insert blanks according to 'shiftwidth'
set('autoindent', true) -- Use same indenting on new lines
set('shiftround', true) -- Round indent to multiple of 'shiftwidth'
set('tabstop', 2)
set('shiftwidth', 2)
set('textwidth', 80)
set('softtabstop', -1)
set('expandtab', true)
set('smartindent', true)

-- Editor UI Appearance
set('ruler', true)
set('laststatus', 0)
set('showcmd', false)
set('showtabline', 0)
set('showmode', false)
set('showbreak', [[↪ ]])
set('encoding', 'utf-8')
set('background', 'dark')
set('colorcolumn', '+1')
set('cursorline', true)
set('cursorcolumn', false)
set('termguicolors', true)
set('shortmess', 'aoOTIcF')
set('guicursor', 'n-v-c-sm:block,i-ci-ve:block,r-cr-o:block')
set('sidescrolloff', 5)
set('scrolloff', 2)
set('more', false)
set('title', true)
set('titlelen', 70)
set('titlestring', ' ❐ %t %r %m')
set('titleold', '%{fnamemodify(getcwd(), ":t")}')
set('pumheight', 15)
set('pumblend', 10)
set('cmdheight', 2)
set('cmdwinheight', 5)
set('winblend', 10)
set('winwidth', 30)
set('winminwidth', 10)
set('hidden', true)
set('helpheight', 12)
set('previewheight', 12)
set('synmaxcol', 2500)
set('display', 'lastline')
set('lazyredraw', true)
set('equalalways', false)
set('numberwidth', 4)
set('fileencoding', 'utf-8')
set('list', true)
set('number', true)
set('signcolumn', 'yes')
set('relativenumber', true)
set('listchars', 'tab:»•,nbsp:+,trail:·,precedes:,extends:')
set('diffopt',
    'vertical,iwhite,hiddenoff,foldcolumn:0,context:4,algorithm:histogram,indent-heuristic')
set('fillchars',
    'vert:▕,fold: ,eob: ,diff:─,msgsep: ,foldopen:▾,foldsep:│,foldclose:▸,eob: ')

-- Behavior
set('eadirection', 'hor')
set('swapfile', false)
set('undofile', true)
set('concealcursor', 'niv')
set('conceallevel', 0)
set('wrap', false)
set('report', 2)
set('backup', false)
set('history', 2000)
set('writebackup', false)
set('undolevels', 1000)
set('shell', '/bin/zsh')
set('errorbells', false)
set('splitbelow', true)
set('splitright', true)
set('mouse', 'a')
set('linebreak', true)
set('maxmempattern', 1300)
set('inccommand', 'nosplit')
set('switchbuf', 'useopen,usetab,vsplit')
set('complete', '.,w,b,k') -- No wins, buffs, tags, include scanning
set('completeopt', 'menu,menuone,noselect,noinsert')
set('iskeyword', '@,48-57,_,192-255,-,#') -- Treat dash separated words as a word text object'
set('breakat', [[\ \	;:,!?]]) -- Long lines break chars
set('startofline', false) -- Cursor in same column for few commands
set('whichwrap', 'h,l,<,>,[,],~') -- Move to following line on certain keys
set('backspace', 'indent,eol,start') -- Intuitive backspacing in insert mode
set('showfulltag', true) -- Show tag and tidy search in completion
set('joinspaces', false) -- Insert only one space when joining lines that contain sentence-terminating punctuation like `.`.
set('jumpoptions', 'stack') -- list of words that change the behavior of the jumplist
set('virtualedit', 'block') -- list of words that change the behavior of the jumplist
set('magic', true) -- list of words that change the behavior of the jumplist

-- Searching
set('grepprg',
    [[rg --hidden --glob "!.git" --no-heading --smart-case --vimgrep --follow $*]])
set('grepformat', '%f:%l:%c:%m')
set('smartcase', true)
set('ignorecase', true)
set('infercase', true)
set('incsearch', true)
set('hlsearch', true)
set('wrapscan', true)
set('showmatch', true)
set('matchpairs', '(:),{:},[:]')
set('matchtime', 1)

-- Wildmenu
set('wildignore',
    '*.so,.git,.hg,.svn,.stversions,*.pyc,*.spl,*.o,*.out,*~,%*,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**,*/.sass-cache/*,application/vendor/**,**/vendor/ckeditor/**,media/vendor/**,__pycache__,*.egg-info')
set('wildmode', 'longest,full')
set('wildoptions', 'pum')
set('wildignorecase', true)

-- What to save for views and sessions:
set('clipboard', 'unnamedplus')
set('shada', "!,'300,<50,@100,s10,h")
set('viewoptions', 'cursor,folds')
set('sessionoptions', 'curdir,help,tabpages,winsize')

-- Binds
local function nmap(lhs, rhs, opts)
  local options = {noremap = false}
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap('n', lhs, rhs, options)
end

local function vmap(lhs, rhs, opts)
  local options = {noremap = false}
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap('v', lhs, rhs, options)
end

local function nnoremap(lhs, rhs, opts)
  local options = {noremap = true, silent = true}
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap('n', lhs, rhs, options)
end

local function tnoremap(lhs, rhs, opts)
  local options = {noremap = true, silent = true}
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap('t', lhs, rhs, options)
end

local function vnoremap(lhs, rhs, opts)
  local options = {noremap = true, silent = true}
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap('v', lhs, rhs, options)
end

local function xnoremap(lhs, rhs, opts)
  local options = {noremap = true, silent = true}
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap('x', lhs, rhs, options)
end

local g = vim.g
g["mapleader"] = " "
g["maplocalleader"] = " "
g["completion_confirm_key"] = ""

-- nnoremap('n', 'j')
nnoremap("<Leader>ax", ":wq!<CR>")
nnoremap("<Leader>az", ":q!<CR>")
nnoremap('<Leader>x', ':q<CR>')
nnoremap('<C-z>', ':undo<CR>')
xnoremap('K', ":m '<-2<CR>gv=gv")
xnoremap('N', ":m '>+1<CR>gv=gv")
nnoremap("<Leader>aO", ":set fo-=cro<CR>") -- Close all folds
nnoremap('<C-c>', '<Esc>')
tnoremap('<Esc>', '<C-\\><C-N>')

-- Move selected line / block of text in visual mode
xnoremap('K', ":m '<-2<CR>gv=gv")
xnoremap('N', ":m '>+1<CR>gv=gv")

-- actions
nnoremap("<Leader>=", "<C-W>=")
nnoremap("<Leader>ah", "<C-W>s")
nnoremap("<Leader>av", "<C-W>v")
nnoremap("<Leader>an", ":let @/ = ''<CR>")
nnoremap("<Leader>aN", ":set nonumber!<CR>")
nnoremap("<Leader>aR", ":set norelativenumber!<CR>")
nnoremap("<Leader><Leader>", ":bdelete<CR>")
nnoremap("<Leader>ad", ":bdelete!<CR>")

-- Next greatest remap ever : asbjornHaland
nnoremap('<Leader>y', '"+y')
vnoremap('<Leader>y', '"+y')
nnoremap('<Leader>aY', 'gg"+yG')
nnoremap('<Leader>aV', 'gg"+VG')
nnoremap('<Leader>aD', 'gg"+VGd')

-- Use alt + hjkl to resize windows
nnoremap('<M-n>', ':resize -2<CR>')
nnoremap('<M-k>', ':resize +2<CR>')
nnoremap('<M-h>', ':vertical resize -2<CR>')
nnoremap('<M-l>', ':vertical resize +2<CR>')

-- Search Files
nnoremap('<Leader>chw', ':h <C-R>=expand("<cword>")<CR><CR>')
nnoremap('<Leader>bs', '/<C-R>=escape(expand("<cWORD>"), "/")<CR><CR>')

-- TAB in general mode will move to text buffer, SHIFT-TAB will go back
nnoremap('<TAB>', ':bnext<CR>')
nnoremap('<S-TAB>', ':bprevious<CR>')

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

_G.enhance_jk_move = function(key)
  vim.cmd [[packadd accelerated-jk]]
  local map = key == 'n' and '<Plug>(accelerated_jk_j)' or
                  '<Plug>(accelerated_jk_gk)'
  return t(map)
end

-- Keymaps
-- acceleratedjk
nmap("n", 'v:lua.enhance_jk_move("n")', {silent = true, expr = true})
nmap("k", 'v:lua.enhance_jk_move("k")', {silent = true, expr = true})

-- Kommentary
nmap("<leader>/", "<Plug>kommentary_line_default")
nmap("<leader>a/", "<Plug>kommentary_motion_default")
vmap("<leader>/", "<Plug>kommentary_visual_default")

-- Plugins
local execute = vim.api.nvim_command
local fn = vim.fn

execute "packadd packer.nvim"

--- Check if a file or directory exists in this path
local function require_plugin(plugin)
  local plugin_prefix = fn.stdpath("data") .. "/site/pack/packer/opt/"

  local plugin_path = plugin_prefix .. plugin .. "/"
  --  print('test '..plugin_path)
  local ok, err, code = os.rename(plugin_path, plugin_path)
  if not ok then
    if code == 13 then
      -- Permission denied, but it exists
      return true
    end
  end
  --  print(ok, err, code)
  if ok then
    vim.cmd("packadd " .. plugin)
  end
  return ok, err, code
end

require('packer').startup(function(use)
  use {'wbthomason/packer.nvim', opt = true}
  -- use {'franbach/miramare', config = vim.cmd [[colo miramare]]}
  use {'razak17/zephyr-nvim', config = vim.cmd [[colo zephyr]]}
  use {'tpope/vim-surround', event = {'BufReadPre', 'BufNewFile'}}
  use {
    'b3nj5m1n/kommentary',
    event = {'BufReadPre', 'BufNewFile'},
    config = function()
      require('kommentary.config').configure_language("default", {
        prefer_single_line_comments = true
      })
    end
  }
  use {
    'norcalli/nvim-colorizer.lua',
    ft = {'html', 'css', 'sass', 'vim', 'typescript', 'typescriptreact'},
    config = function()
      require'colorizer'.setup {
        css = {rgb_fn = true},
        scss = {rgb_fn = true},
        sass = {rgb_fn = true},
        stylus = {rgb_fn = true},
        vim = {names = true},
        tmux = {names = false},
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        html = {mode = 'foreground'}
      }
    end
  }
  use {
    'romainl/vim-cool',
    event = {'BufRead', 'BufNewFile'},
    config = function()
      vim.g.CoolTotalMatches = 1
    end
  }

  use {'rhysd/accelerated-jk', opt = true, event = "VimEnter"}

  require_plugin('kommentary')
  require_plugin('vim-surround')
  require_plugin('vim-cool')
  require_plugin('nvim-colorizer')
end)

