""""" VIM config file
"""" Jan Andrle

""" Helpers
    function MapSetToggle(key, opt)
        let cmd = ':set '.a:opt.'! \| set '.a:opt."?\<CR>"
        exec 'nnoremap '.a:key.' '.cmd
        exec 'vnoremap <silent>'.a:key.' <Esc>'.cmd." gv"
        "exec 'inoremap '.a:key." \<C-O>".cmd
    endfunction
    command -nargs=+ MapSetToggle call MapSetToggle(<f-args>)
    function MapSmartKey(key_name)
        let cmd = 'Smart'.a:key_name
        exec 'nmap <silent><'.a:key_name.'> :call '.cmd.'("n")<CR>'
        exec 'imap <silent><'.a:key_name.'> <C-r>='.cmd.'("i")<CR>'
        exec 'vmap <silent><'.a:key_name.'> <Esc>:call '.cmd.'("v")<CR>'
    endfunction
    command -nargs=+ MapSmartKey call MapSmartKey(<f-args>)

""" Keys combinations for editing/reading
    let mapleader = ","
    nnoremap <F2> :set invpaste paste?<CR>
    set pastetoggle=<F2>
    set showmode
    nmap ; :
    imap ii <Esc>
    nmap <s-u> <c-r>
    nmap ž ^
    MapSmartKey Home
    MapSmartKey End
    nmap <c-down> gj
    nmap <c-up> gk
    nmap <silent> ú : let @/ = ""<cr>
                                " Paste to line end with space
    nnoremap <leader>pa a<right><space><esc>p
    nnoremap <leader>p<s-a> <s-a><right><space><esc>p
    nnoremap <leader>,o <s-a>,<cr><esc>
    nnoremap <leader>;o <s-a>;<cr><esc>
    nnoremap <leader>o o<esc>
    nnoremap <leader><s-o> <s-o><esc>
                                " Visual mode pressing * or # searches for the current selection. From an idea by Michael Naumann.
    vnoremap <silent> * :<C-u>call VisualSelection('')<CR>/<C-R>=@/<CR><CR>
    vnoremap <silent> # :<C-u>call VisualSelection('')<CR>?<C-R>=@/<CR><CR>

""" Syntax
    set cursorline
    set list                                        " Highlight spec. chars / Display extra whitespace
    MapSetToggle TS list
    set listchars=tab:»·,trail:·,nbsp:~,space:·
    highlight SpecialKey guifg=darkgrey ctermfg=darkgrey
    highlight Comment cterm=italic ctermbg=black guibg=black
    highlight CursorLine cterm=underline gui=underline ctermbg=black guibg=black
    highlight ColorColumn ctermbg=darkgrey guibg=darkgrey
                                                    " Switch syntax highlighting on, when the terminal has colors. Also switch on highlighting the last used search pattern.
    if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
      syntax on
    endif
                                                    " Enable filetype plugins
    if has("autocmd")
      " Enable file type detection
      filetype on
      " Treat .json files as .js
      autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
    endif
    let g:html_indent_tags = 'li\|p'                " Treat <li> and <p> tags like the block tags they are

""" Opening+files
    set encoding=utf8                           " Set utf8 as standard encoding and en_US as the standard language
    set path+=**                                " File matching for `:find`
    set autoread                                " Auto reload changed files
    au FocusGained,BufEnter * checktime         " …still autoread
                                                " Return to last edit position when opening files (You want this!)
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    if has("autocmd")
        autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
    endif

""" Saving files
                                                " Save a file as root (:W)
    command W w !sudo tee "%" > /dev/null
    set nobackup nowritebackup noswapfile       " Turn off backup files
    set history=500                             " How many lines of history has to remember
                                                " Savig edit history for next oppening
    try
        set undodir=~/.vim/undodir
        set undofile
    catch
    endtry

""" General editor visuals
    set bg=dark
    set laststatus=2                            " Show status line on startup
    set statusline+=%r%{getcwd()}/%f%h\ 
    set statusline+=%=\ 
    set statusline+=%{&fileencoding?&fileencoding:&encoding}
    set statusline+=\[%{&fileformat}\]
    set statusline+=\ %p%%
    set statusline+=\ %l:%c\ 
    set statusline+=\ 
    set ruler                                   " Always show current position
    set noerrorbells novisualbell               " Turn off visual and audible bells
    set showcmd                                 " Show size of visual selection
    set number "relativenumber                  " Enable line numbers
    "set numberwidth=5
    MapSetToggle TN relativenumber
    set foldcolumn=0                            " Add a bit extra margin to the left
    set scrolloff=5                             " Leave lines of buffer when scrolling
    set sidescrolloff=10                        " Leave characters of horizontal buffer when scrolling
    set textwidth=120                           " Line width marker
    set colorcolumn=+1                          " …marker visual
                                                " Disable scrollbars (real hackers don't use scrollbars for navigation!)
    set guioptions-=r
    set guioptions-=R
    set guioptions-=l
    set guioptions-=L

""" UI/UX
    set clipboard=unnamed                       " Use the OS clipboard by default (on versions compiled with `+clipboard`)
    set lazyredraw                              " Reduce the redraw frequency
    set ttyfast                                 " Send more characters in fast terminals
    set hlsearch                                " Highlight search results
    set ignorecase smartcase                    " Search queries intelligently set case
    set incsearch                               " Show search results as you type
    set timeoutlen=1000 ttimeoutlen=0           " Remove timeout when hitting escape

""" Multiple buffers
    set splitright                              " Open new splits to the right
    set splitbelow                              " Open new splits to the bottom

""" Editing experience
    set backspace=indent,eol,start              " Allow cursor keys in insert mode:  http://vi.stackexchange.com/a/2163
    set nowrap                                  " Don't wrap long lines
    MapSetToggle TW wrap
    set expandtab smarttab                      " Use spaces instead of tabs and be smart
    set shiftwidth=4 tabstop=4 softtabstop=4    " Set spaces for tabs everywhere
    set noai nosi                               " Auto indent / Smart indent
    set wildmenu                                " Tab autocomplete in command mode
                                                " Tab completion: will insert tab at beginning of line, will use completion if not at beginning
    set wildmode=list:longest,list:full

""" Functions
    function SmartHome(mode)
        let curcol = col(".")
        "gravitate towards beginning for wrapped lines
        if curcol > indent(".") + 2
            call cursor(0, curcol - 1)
        endif
        if curcol == 1 || curcol > indent(".") + 1
            if &wrap
                normal g^
            else
                normal ^
            endif
        else
            if &wrap
                normal g0
            else
                normal 0
            endif
        endif
        if a:mode == "v"
            normal msgv`s
        endif
        return ""
    endfunction
    function SmartEnd(mode)
        let curcol = col(".")
        let lastcol = a:mode == "i" ? col("$") : col("$") - 1
        "gravitate towards ending for wrapped lines
        if curcol < lastcol - 1
            call cursor(0, curcol + 1)
        endif
        if curcol < lastcol
            if &wrap
                normal g$
            else
                normal $
            endif
        else
            normal g_
        endif
        "correct edit mode cursor position, put after current character
        if a:mode == "i"
            call cursor(0, col(".") + 1)
        endif
        if a:mode == "v"
            normal msgv`s
        endif
        return ""
    endfunction
    function! VisualSelection(direction) range
        let l:saved_reg = @"
        execute "normal! vgvy"
        let l:pattern = escape(@", "\\/.*'$^~[]")
        let @/ = substitute(l:pattern, "\n$", "", "")
        let @" = l:saved_reg
    endfunction
    fun! CleanExtraSpaces()
        let save_cursor = getpos(".")
        let old_query = getreg('/')
        silent! %s/\s\+$//e
        call setpos('.', save_cursor)
        call setreg('/', old_query)
    endfun
