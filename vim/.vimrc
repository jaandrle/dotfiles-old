" Jan Andrle
" ▓ ▓ ▓ GENERAL ▓ ▓ ▓
set path+=**                           " Not only `:find` navigation for files
set autoread                           " Auto reload changed files
au FocusGained,BufEnter * checktime
set wildmenu                           " Tab autocomplete in command mode
set backspace=indent,eol,start         " http://vi.stackexchange.com/a/2163
set clipboard=unnamed                  " Clipboard support (OSX)
set laststatus=2                       " Show status line on startup
set statusline=\ %{HasPaste()}\ 
set statusline+=%r%{getcwd()}/%f%h\ 
set statusline+=%=\ 
set statusline+=%{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c\ 
set statusline+=\ 
set ruler                              " Always show current position
set splitright                         " Open new splits to the right
set splitbelow                         " Open new splits to the bottom
set lazyredraw                         " Reduce the redraw frequency
set ttyfast                            " Send more characters in fast terminals
set nowrap                             " Don't wrap long lines
set nobackup nowritebackup noswapfile  " Turn off backup files
set noerrorbells novisualbell          " Turn off visual and audible bells
set expandtab smarttab                 " Use spaces instead of tabs and be smart
set shiftwidth=4 tabstop=4             " Two spaces for tabs everywhere
set ai si                              " Auto indent / Smart indent
set history=500                        " How many lines of history has to remember
set hlsearch                           " Highlight search results
set ignorecase smartcase               " Search queries intelligently set case
set incsearch                          " Show search results as you type
set timeoutlen=1000 ttimeoutlen=0      " Remove timeout when hitting escape
set showcmd                            " Show size of visual selection
" ▓ ▓ ▓ SYNTAX ▓ ▓ ▓
" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
endif
" Enable filetype plugins
filetype plugin on
filetype indent on
" Highlight spec. chars / Display extra whitespace
set list
set listchars=tab:»·,trail:·,nbsp:·,space:·
highlight SpecialKey guifg=darkgrey ctermfg=darkgrey
highlight Comment cterm=italic " Showcase comments in italics
highlight ColorColumn ctermbg=darkgrey guibg=darkgrey
" ▓ ▓ ▓ INTERFACE ▓ ▓ ▓
set number relativenumber               " Enable line numbers
set numberwidth=5
:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
:  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
:augroup END
set foldcolumn=0                        " Add a bit extra margin to the left
set scrolloff=5                         " Leave 5 lines of buffer when scrolling
set sidescrolloff=10                    " Leave 10 characters of horizontal buffer when scrolling
" Make it obvious where 80 characters is
set textwidth=120
set colorcolumn=+1
" Tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
set wildmode=list:longest,list:full
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<Tab>"
    else
        return "\<C-p>"
    endif
endfunction
inoremap <Tab> <C-r>=InsertTabWrapper()<CR>
inoremap <S-Tab> <C-n>
" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'
" ▓ ▓ ▓ FUNCTIONS ▓ ▓ ▓
" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun
if has("autocmd")
    autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
endif
function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"
    
    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")
    
    if a:direction == 'gv'
        call CmdLine("Ack '" . l:pattern . "' " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif
    
    let @/ = l:pattern
    let @" = l:saved_reg
endfunction
" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    endif
    return ''
endfunction
" ▓ ▓ ▓ KEYBOARD ▓ ▓ ▓
let mapleader = ","
nnoremap <leader>p i<right><space><esc>p
nnoremap <leader><shift>p i<right><esc><shift>p<space>
set pastetoggle=<F2>
nmap ; :
:imap ii <Esc>          "Remap ESC to ii
nmap ú : let @/ = ""<cr>
" Move a line of text using ALT+[jk]
nmap mj mz:m+<cr>`z
nmap mk mz:m-2<cr>`z
vmap mj :m'>+<cr>`<my`>mzgv`yo`z
vmap mk :m'<-2<cr>`>my`<mzgv`yo`z
" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>
" ▓ ▓ ▓ EXTRA ▓ ▓ ▓
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Turn persistent undo on 
"    means that you can undo even when you close a buffer/VIM
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
try
    set undodir=~/.vim_runtime/temp_dirs/undodir
    set undofile
catch
endtry
