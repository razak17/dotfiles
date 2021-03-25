" -----------------------------------------------------------------------------
" Color settings
" -----------------------------------------------------------------------------

" Enable 24-bit true colors if your terminal supports it.
if (has("termguicolors"))
  " https://github.com/vim/vim/issues/993#issuecomment-255651605
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

  set termguicolors
endif

" Enable syntax highlighting.
syntax on

" Set the color scheme to dark.
set background=dark

" -----------------------------------------------------------------------------
" Status line
" -----------------------------------------------------------------------------

" Heavily inspired by: https://github.com/junegunn/dotfiles/blob/master/vimrc
function! s:statusline_expr()
  let mod = "%{&modified ? '[+] ' : !&modifiable ? '[x] ' : ''}"
  let ro  = "%{&readonly ? '[RO] ' : ''}"
  let ft  = "%{len(&filetype) ? '['.&filetype.'] ' : ''}"
  let fug = "%{exists('g:loaded_fugitive') ? fugitive#statusline() : ''}"
  let sep = ' %= '
  let pos = ' %-12(%l : %c%V%) '
  let pct = ' %P'

  return '[%n] %f %<'.mod.ro.ft.fug.sep.pos.'%*'.pct
endfunction

let &statusline = s:statusline_expr()

" -----------------------------------------------------------------------------
" Basic Settings
"   Research any of these by running :help <setting>
" -----------------------------------------------------------------------------

let mapleader=" "
let maplocalleader=" "


set exrc
set secure
set autoindent
set autoread
set backspace=indent,eol,start
set backupdir=/tmp//,.
set clipboard=unnamedplus
set colorcolumn=80
set complete+=kspell
set completeopt=menuone,longest
set cryptmethod=blowfish2
set cursorline
set directory=/tmp//,.
set encoding=utf-8
set expandtab smarttab
set formatoptions=tcqrn1
set hidden
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set matchpairs+=<:> " Use % to jump between pairs
set mmp=5000
set modelines=2
set mouse=a
set nocompatible
set noerrorbells visualbell t_vb=
set noshiftround
set nospell
set nostartofline
set number relativenumber
set regexpengine=1
set ruler
set scrolloff=3
set shiftwidth=2
set showcmd
set showmatch
set shortmess+=c
set showmode
set smartcase
set softtabstop=2
set spelllang=en_us
set splitbelow
set splitright
set tabstop=2
set textwidth=0
set ttimeout
set ttyfast
set ttymouse=sgr
set undodir=~/.vim/undodir
set undofile
set virtualedit=block
set whichwrap=b,s,<,>
set wildmenu
set wildmode=full
set wrap

" -----------------------------------------------------------------------------
" Basic mappings
" -----------------------------------------------------------------------------
nnoremap n j
nnoremap z u

" Move selected line / block of text in visual mode
" shift + k to move up
" shift + j to move down
xnoremap K :move '<-2<CR>gv-gv
xnoremap J :move '>+1<CR>gv-gv
xnoremap N :move '>+1<CR>gv-gv

if !exists('g:vscode')
  " g Leader key
  let mapleader=" "
  let localleader=" "
  nnoremap <Space> <Nop>

  " Better Navigation
  nnoremap <C-h> <C-w>h
  nnoremap <C-j> <C-w>j
  nnoremap <C-k> <C-w>k
  nnoremap <C-l> <C-w>l

  " I hate escape more than anything else
  inoremap jk <Esc>
  inoremap jj <Esc>
  inoremap kj <Esc>

  " Easy CAPS
  inoremap <c-u> <ESC>viwUi
  nnoremap <c-u> viwU<Esc>

  " Better nav for omnicomplete
  inoremap <expr> <c-j> ("\<C-n>")
  inoremap <expr> <c-k> ("\<C-p>")

  " Use alt + hjkl to resize windows
  nnoremap <M-j>    :resize -2<CR>
  nnoremap <M-k>    :resize +2<CR>
  nnoremap <M-h>    :vertical resize -2<CR>
  nnoremap <M-l>    :vertical resize +2<CR>

  " Fast Comments
  nnoremap <space>/ :Commentary<CR>

  " Window resize
  nnoremap <leader>cv :wincmd v<bar> :Ex <bar> :vertical resize 30<CR>
  nnoremap <Leader>+ :vertical resize +5<CR>
  nnoremap <Leader>- :vertical resize -5<CR>

  " Search files
  noremap <Leader>cf :Files<CR>
  nnoremap <leader>cw :Rg <C-R>=expand("<cword>")<CR><CR>
  nnoremap <Leader>cs :Rg<SPACE>
  nnoremap <leader>chw :h <C-R>=expand("<cword>")<CR><CR>
  " nnoremap rm :call delete(expand('%')) \| bdelete!<CR>

  " Terminal window navigation
  tnoremap <C-h> <C-\><C-N><C-w>h
  tnoremap <C-j> <C-\><C-N><C-w>j
  tnoremap <C-k> <C-\><C-N><C-w>k
  tnoremap <C-l> <C-\><C-N><C-w>l
  inoremap <C-h> <C-\><C-N><C-w>h
  inoremap <C-j> <C-\><C-N><C-w>j
  inoremap <C-k> <C-\><C-N><C-w>k
  inoremap <C-l> <C-\><C-N><C-w>l
  tnoremap <Esc> <C-\><C-n>

  " TAB in general mode will move to text buffer
  nnoremap <TAB> :bnext<CR>
  " SHIFT-TAB will go back
  nnoremap <S-TAB> :bprevious<CR>

  " Alternate way to save
  nnoremap <C-s> :w<CR>
  " Alternate way to quit
  nnoremap <C-Q> :wq!<CR>
  nnoremap <Leader>x :q<CR>
  " Use control-c instead of escape
  nnoremap <C-c> <Esc>
  " <TAB>: completion.
  inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

  " Better tabbing
  vnoremap < <gv
  vnoremap > >gv

  " greatest remap ever
  vnoremap <leader>p "_dP

  " next greatest remap ever : asbjornHaland
  nnoremap <leader>y "+y
  vnoremap <leader>y "+y
  nnoremap <leader>Y gg"+yG

  " Other remaps
  " nnoremap <Leader>ee oif err != nil {<CR>log.Fatalf("%+v\n", err)<CR>}<CR><esc>kkI<esc>
  vnoremap J :m '>+1<CR>gv=gv
  vnoremap K :m '<-2<CR>gv=gv
  nnoremap <Leader><CR> :so ~/.config/nvim/init.vim<CR>
  " nnoremap <leader>gc :GBranches<CR>
  " nnoremap <leader>ga :Git fetch --all<CR>
  " nmap <leader>gf :diffget //3<CR>
  " nmap <leader>gk :diffget //2<CR>
  " nmap <leader>gs :G<CR>
  nnoremap <leader>grum :Git rebase upstream/master<CR>
  nnoremap <leader>grom :Git rebase origin/master<CR>
  nnoremap <leader>bs /<C-R>=escape(expand("<cWORD>"), "/")<CR><CR>
endif


" -----------------------------------------------------------------------------
" Basic autocommands
" -----------------------------------------------------------------------------

" Auto-resize splits when Vim gets resized.
autocmd VimResized * wincmd =

" Update a buffer's contents on focus if it changed outside of Vim.
au FocusGained,BufEnter * :checktime

" Unset paste on InsertLeave.
autocmd InsertLeave * silent! set nopaste

" Make sure all types of requirements.txt files get syntax highlighting.
autocmd BufNewFile,BufRead requirements*.txt set syntax=python

" Ensure tabs don't get converted to spaces in Makefiles.
autocmd FileType make setlocal noexpandtab

" Only show the cursor line in the active buffer.
augroup CursorLine
    au!
    au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END

" ----------------------------------------------------------------------------
" Basic commands
" ----------------------------------------------------------------------------

