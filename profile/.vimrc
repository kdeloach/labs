" All system-wide defaults are set in $VIMRUNTIME/debian.vim and sourced by
" the call to :runtime you can find below.  If you wish to change any of those
" settings, you should do it in this file (/etc/vim/vimrc), since debian.vim
" will be overwritten everytime an upgrade of the vim packages is performed.
" It is recommended to make changes after sourcing debian.vim since it alters
" the value of the 'compatible' option.

" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes numerous
" options, so any other options should be set AFTER setting 'compatible'.
" set compatible

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'ambv/black'
Plugin 'sheerun/vim-polyglot'
Plugin 'fatih/vim-go'
Plugin 'prettier/vim-prettier'
Plugin 'simnalamburt/vim-mundo'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
if has("syntax")
  syntax on
endif

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
"set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
if has("autocmd")
  filetype plugin indent on
endif

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
set showcmd		" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching
set smartcase		" Do smart case matching
set incsearch		" Incremental search
set autowrite		" Automatically save before commands like :next and :make
set hidden		" Hide buffers when they are abandoned
set mouse=a		" Enable mouse usage (all modes)

" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif

set nowrap
set number

set colorcolumn=80
highlight ColorColumn ctermbg=7
highlight MatchParen ctermbg=7 ctermfg=none

set nosmartindent
set tabstop=4
set shiftwidth=4
set expandtab
set so=999

set undofile
set undodir=~/.vim/undo

set backupdir=~/.vim/swp
set directory=~/.vim/swp

highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

map <C-e> :NERDTreeToggle<CR>
map <C-f> :NERDTreeFind<CR>
let NERDTreeIgnore = ['\.pyc$']

" Highlight search matches
set hlsearch

" Reload file when it changes on disk
set autoread

" Format Python code upon save
autocmd BufWritePre *.py execute ':Black'

" vim-prettier
let g:prettier#autoformat = 0

" use .prettierrc  instead of plugin defaults
let g:prettier#config#config_precedence = 'prefer-file'

autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.graphql,*.vue PrettierAsync

" don't override default buffer on paste
vnoremap p "_dP

autocmd FileType javascript setlocal shiftwidth=2 tabstop=2

let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git\|land_scrub_output\|exported_tiles'

" https://stackoverflow.com/questions/18902537/why-does-vim-automatically-change-comma-delimited-csv-to-pipes
let g:csv_no_conceal = 1

" Replace entire file contents with X clipboard
nnoremap <leader>p :%d<CR>:r !xclip -selection clipboard -o<CR>
