"テストですね 漢字

set term=xterm
filetype plugin on

"display formatting
set tabstop=5
set shiftwidth=5
set noexpandtab

"fix colors
set t_Co=16
"let &t_AB="\e[48;5;%dm"
"let &t_AF="\e[38;5;%dm"
set background=dark
colorscheme solarized

"fix our backspace
"set t_kb=^h
"imap <C-Del> ^h
set backspace=2

"fix our encoding
set enc=utf8
set termencoding=utf8
set fileencoding=utf8
set fileformat=unix

"enable airline
set laststatus=2
let g:airline_powerline_fonts = 1
let g:airline_theme="bubblegum"
syntax on

"turn on line numbers
set number

"highlight column 80
set colorcolumn=80

"prevent insert mode after line insertion
map <Enter> o<ESC>
map <S-Enter> O<ESC>

"ctrl-s to save
imap <C-s> <ESC>:w<CR>
map <C-s> <ESC>:w<CR>

"shift-space to autocomplete
inoremap <S-Space> <C-p>

"easy tabbing
map <Tab> >>
map <S-Tab> << 
