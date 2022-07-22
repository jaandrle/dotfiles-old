scriptencoding utf-8 | set encoding=utf-8
let $BASH_ENV = "~/.bashrc"
packadd! matchit
set hidden
set confirm
set belloff=esc
set showcmd cmdheight=2 showmode
set wildmenu wildmode=list:longest,list:full
set history=500
set nobackup nowritebackup noswapfile
try
	set undodir=~/.vim/undodir undofile | catch | endtry

nmap s <nop>
vmap s <nop>
nmap S <nop>
vmap S <nop>
let mapleader= "s"

nnoremap <leader>v :
nnoremap <leader>a @
nnoremap <leader>A @@
nnoremap <leader>u U
nnoremap U <c-r>
nnoremap <leader>l <c-]>
nmap <silent><leader>m :nohlsearch<bar>diffupdate<cr>

nnoremap <leader>o o<space><bs><esc>
nnoremap <leader>O O<space><bs><esc>
nnoremap <s-k> a<cr><esc>
for l in [ 'y', 'p', 'P', 'd' ] | for m in [ 'n', 'v' ]
	execute m.'noremap <leader>'.l.' "+'.l | endfor | endfor

cabbrev <expr> %PWD%  execute('pwd')
cabbrev <expr> %CD%   fnameescape(expand('%:p:h'))
cabbrev <expr> %CW%   expand('<cword>')

set cursorline cursorcolumn
set number "foldcolumn=2
set colorcolumn=+1
set breakindent breakindentopt=shift:2 showbreak=↳ 
set scrolloff=5 sidescrolloff=10										" offset for lines/columns when scrolling
set autowrite autoread | autocmd FocusGained,BufEnter *.* checktime
set modeline
set hlsearch incsearch
set smarttab
command! -nargs=1 SETtab let &shiftwidth=<q-args> | let &tabstop=<q-args> | let &softtabstop=<q-args>
SETtab 4
set showmatch
set backspace=indent,eol,start
set shiftround autoindent
filetype plugin indent on
colorscheme codedark
if ($TERM =~ '256' && has("termguicolors"))
	set termguicolors | endif
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
	syntax on | endif
set list listchars=tab:»·,trail:·,extends:#,nbsp:~,space:·
augroup syntax_sync_min_lines
	autocmd!
	autocmd Syntax * syn sync minlines=200
augroup END
command! -nargs=? SETspell if <q-args>==&spelllang || <q-args>=='' | set spell! | else | set spell | set spelllang=<args> | endif | if &spell | set spelllang | endif

command! -nargs=0 SETFOLDregions set foldmethod=marker
command! -nargs=1 SETFOLDindent set foldmethod=indent | let &foldlevel=<q-args> | let &foldnestmax=<q-args>+1
command! -nargs=* SETFOLDindents set foldmethod=indent | let &foldlevel=split(<q-args>, ' ')[0] | let &foldnestmax=split(<q-args>, ' ')[1]
set foldmarker=#region,#endregion

set viewoptions=cursor,folds
augroup remember__view
	autocmd!
	autocmd BufWinLeave *.* if &buflisted | mkview | endif
	autocmd BufWinEnter *.* silent! loadview
augroup END

inoremap <silent><expr> <tab> pumvisible() ? "\<c-n>" : <sid>check_back_space() ? "\<tab>" : "\<c-n>"
inoremap <silent><expr> <s-tab> pumvisible() ? "\<c-p>" : "\<c-h>"
function! s:check_back_space() abort
	let col = col('.') - 1
	return !col || getline('.')[col - 1]  =~# '\s'
endfunction
