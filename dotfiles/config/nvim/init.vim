" download vim-plug if necessary
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl --silent -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif

call plug#begin()

Plug 'altercation/vim-colors-solarized'
Plug 'bling/vim-airline'
Plug 'calebsmith/vim-lambdify'
Plug 'ElmCast/elm-vim'
Plug 'elixir-lang/vim-elixir'
Plug 'godlygeek/tabular'
Plug 'guns/vim-clojure-highlight'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'kien/ctrlp.vim'
Plug 'kien/rainbow_parentheses.vim'
Plug 'LnL7/vim-nix'
Plug 'majutsushi/tagbar'
Plug 'matze/vim-move'
Plug 'mhinz/vim-signify'
Plug 'moll/vim-node'
Plug 'othree/html5.vim'
Plug 'paredit.vim'
Plug 'phongvcao/vim-stardict'
Plug 'rodjek/vim-puppet'
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/syntastic'
Plug 'Shougo/unite.vim' | Plug 'Quramy/vison'
Plug 'tmux-plugins/vim-tmux'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fireplace'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-leiningen'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-rake'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-tbone'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-vinegar'

call plug#end()

" activate mouse in all modes
set mouse=a

" show some invisible characters
set list

" enable line numbers
set number

" scroll vertically with 4 extra lines
set scrolloff=4

" persistent undo history
set undofile
set undodir=$HOME/.config/.nvim/undo
silent call system('mkdir -p ' . &undodir)

" disable spacebar right-motion in normal mode
nnoremap <Space> <Nop>
" use it for a leader key instead
let mapleader=" "

" map semicolon to colon
" That way you dont need to hold Shift to enter cmdline mode
map ; :

" map `Y` to yank to the end of the line
" You can still yank the entire line with `yy`
nmap Y y$

" map <tab> to match-motion
nnoremap <tab> %
vnoremap <tab> %
onoremap <tab> %

" recognize some file endings I use
au BufRead,BufNewFile *.md set filetype=markdown
au BufRead,BufNewFile *.bats set filetype=bash

" enable rubocop
let g:syntastic_ruby_checkers = ['mri', 'rubocop']

let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1

" Colors
set background=dark
let g:solarized_termcolors=256
let g:solarized_termtrans=1
silent! colorscheme solarized

" Rebalance splits when the window resizes
au VimResized * :wincmd =

" Enable cursorline on the window with focus
augroup cline
  au!
  au WinLeave,InsertEnter * set nocursorline
  au WinEnter,InsertLeave * set cursorline
augroup END

" highlight when brackets are closed
set showmatch

" treat all search patterns as "very magic"
" (ie, metacharacters are default, literals are escaped)
nnoremap / /\v
vnoremap / /\v
" disable search map highlighting with <leader>/
nnoremap <leader>/ :nohlsearch<cr>
" ignore case of lower-case search strings
set ignorecase
set smartcase

" substitute all matches in a line by default
set gdefault

" show a line-length guide-line (guide-column?)
set colorcolumn=85

" automatically insert comment leaders, enable `gq` and help it recognize
" numbered lists (see :help fo-table for more)
set formatoptions=jrqln

" disable arrow keys in insert mode
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" s to save and q to close
nnoremap s :w<cr>
nnoremap q :q<cr>

" move vertically by displayed row, not file line
nnoremap j gj
nnoremap k gk

" fugitive shortcuts
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>gl :Glog<cr>
nnoremap <leader>gc :Gcommit --verbose<cr>
nnoremap <leader>gg :Ggrep
nnoremap <leader>gmv :Gmove
nnoremap <leader>grm :Gremove

nnoremap <leader>sd :StarDictCursor<CR>
