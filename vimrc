" Disable compatibility with vi
set nocompatible

" activate pathogen plugin manager
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

" generate helptags for every plugin
Helptags

" activate mouse in all modes
set mouse=a

" show some invisible characters
set list

" enable line numbers
set number

" map semicolon to colon
" That way you dont need to hold Shift to enter cmdline mode
map ; :

" map `Y` to yank to the end of the line
" You can still yank the entire line with `yy`
nmap Y y$

" recognize .md files as markdown
au BufRead,BufNewFile *.md set filetype=markdown

" enable rubocop
let g:syntastic_ruby_checkers = ['mri', 'rubocop']

" if our terminal supports escape sequences
if &term == "screen-256color"
  " set the insert mode cursor to a blinking vertical bar
  let &t_SI = "\<Esc>[5 q"
  " in other modes, set the cursor to a blinking block
  let &t_EI = "\<Esc>[1 q"

  " 1 -> blinking block
  " 2 -> solid block
  " 3 -> blinking underscore
  " 4 -> solid underscore
  " 5 -> blinking vertical bar
  " 6 -> solid vertical bar
endif

" Colors
set background=dark
let g:solarized_termcolors=256
let g:solarized_termtrans=1
colorscheme solarized
