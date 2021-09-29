""" VIM config file | Jan Andrle | 2021-09-29 (VIM >=8.1)
"" #region B – Base
    :scriptencoding utf-8                   " Set internal encoding of vim, not needed on neovim, since coc.nvim using some
    set encoding=utf-8                                                 " unicode characters in the file autoload/float.vim
    set hidden                                                                  " TextEdit might fail if hidden is not set.
    set nobackup nowritebackup                                      " Some servers have issues with backup files, see #649.
    set cmdheight=2                                                             " Give more space for displaying messages.
    set updatetime=300 " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable delays and poor user experience.
    set shortmess+=c
                                                                            " Don't pass messages to |ins-completion-menu|.
    if has("nvim-0.5.0") || has("patch-8.1.1564")           " Recently vim can merge signcolumn and number column into one
        set signcolumn=number
    else
        set signcolumn=yes
    endif      " Always show the signcolumn, otherwise it would shift the text each time diagnostics appear/become resolved.
    set cursorline
    set showmode
    set showmatch
    set title                                   " change the terminal's title
    set clipboard=unnamed                       " Use the OS clipboard by default (on versions compiled with `+clipboard`)
    set lazyredraw                              " Reduce the redraw frequency
    set ttyfast                                 " Send more characters in fast terminals
    set path+=**                                " File matching for `:find`
    for ignore in [ '.git', '.npm', 'node_modules' ]
        exec ':set wildignore+=**'.ignore.'**'
    endfor
    set autoread                                " Auto reload changed files
    au FocusGained,BufEnter * checktime         " …still autoread
                                                " Return to last edit position when opening files (You want this!)
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    if has("autocmd")
        autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
    endif
                                                " Save a file as root (:W)
    command! W w !sudo tee > /dev/null %
    set nobackup nowritebackup noswapfile       " Turn off backup files
    set history=500                             " How many lines of history has to remember
                                                " Savig edit history for next oppening
    try
        set undodir=~/.vim/undodir
        set undofile
    catch
    endtry
    augroup remember_folds
        autocmd!
        autocmd BufWinLeave *.* mkview
        autocmd BufWinEnter *.* silent! loadview
    augroup END
    let g:netrw_fastbrowse= 0
    let g:netrw_keepdir= 0
    let g:netrw_localcopydircmd= 'cp -r'
    let g:netrw_liststyle= 3
    hi! link netrwMarkFile Search
    let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro'
    set sessionoptions-=options
"" #endregion B
"" #region EA – Editor Appearance
    colorscheme codedark
    "highlight CocFloating ctermbg=darkgray ctermfg=white
    "highlight SpecialKey guifg=darkgrey ctermfg=darkgrey
    "highlight Comment cterm=italic ctermbg=black guibg=black
    "highlight CursorLine cterm=underline gui=underline ctermbg=black guibg=black
    "highlight ColorColumn ctermbg=darkgrey guibg=darkgrey
    set laststatus=2                                                                           " Show status line on startup
    set statusline+=%r%{getcwd()}/%f%h\ 
    set statusline+=%=\ 
    set statusline+=%{&fileencoding?&fileencoding:&encoding}
    set statusline+=\[%{&fileformat}\]
    set statusline+=\ %p%%
    set statusline+=\ %l:%c\ 
    set statusline+=\ 
    set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
    set ruler                                                                                " Always show current position
    set noerrorbells novisualbell                                                       " Turn off visual and audible bells
    set showcmd                                                                             " Show size of visual selection
    set number                                                                                        " Enable line numbers
    set foldcolumn=2                                                                   " Add a bit extra margin to the left
    set scrolloff=5                                                                  " Leave lines of buffer when scrolling
    set sidescrolloff=10                                             " Leave characters of horizontal buffer when scrolling
    set textwidth=120                                                                                   " Line width marker
    set colorcolumn=+1                                                                                  " …marker visual
    for l in [ 'r', 'R', 'l', 'L' ]                " Disable scrollbars (real hackers don't use scrollbars for navigation!)
        exec ':set guioptions-='.l
    endfor
    set list                                                            " Highlight spec. chars / Display extra whitespace
    set listchars=tab:»·,trail:·,extends:#,nbsp:~,space:·
    set hlsearch                                                                                " Highlight search results
    set ignorecase smartcase                                                        " Search queries intelligently set case
    set incsearch                                                                        " Show search results as you type
    set timeoutlen=1000 ttimeoutlen=0                                                  " Remove timeout when hitting escape
    set completeopt=menuone,preview,noinsert,noselect
    set breakindent
    set breakindentopt=shift:2
    set showbreak=↳ 
    set backspace=indent,eol,start                  " Allow cursor keys in insert mode:  http://vi.stackexchange.com/a/2163
    set nowrap                                                                                      " Don't wrap long lines
    let g:cwordhi#autoload= 1
                                                    " Switch syntax highlighting on, when the terminal has colors. Also switch on highlighting the last used search pattern.
    if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
      syntax on
    endif
    if v:version > 703 || v:version == 703 && has("patch541")
      set formatoptions+=j " Delete comment character when joining commented lines
    endif
"" #endregion EA
"" #region H – Helpers
    function MapSetToggle(key, opt)
        let cmd = ':set '.a:opt.'! \| set '.a:opt."?\<CR>"
        exec 'nnoremap '.a:key.' '.cmd
        exec 'vnoremap <silent>'.a:key.' <Esc>'.cmd." gv"
        "exec 'inoremap '.a:key." \<C-O>".cmd
    endfunction
    command -nargs=+ MapSetToggle call MapSetToggle(<f-args>)
    function MapSmartKey(key_name)
        let cmd = '<sid>Smart'.a:key_name
        exec 'nmap <silent><'.a:key_name.'> :call '.cmd.'("n")<CR>'
        exec 'imap <silent><'.a:key_name.'> <C-r>='.cmd.'("i")<CR>'
        exec 'vmap <silent><'.a:key_name.'> <Esc>:call '.cmd.'("v")<CR>'
    endfunction
    command -nargs=+ MapSmartKey call MapSmartKey(<f-args>)
"" #endregion H
"" #region K – Keys
    set foldmarker=#region,#endregion
    set expandtab smarttab                                                        " Use spaces instead of tabs and be smart
    set shiftwidth=4 tabstop=4 softtabstop=4                                      " Set spaces for tabs everywhere
    set shiftround                                                          " round diff shifts to the base of n*shiftwidth
    set ai si ci                                                                " Auto indent / Smart indent / Copy indent
    set wildmenu                                                                  " Tab autocomplete in command mode
    set wildmode=list:longest,list:full
    let mapleader = "\\"
    nnoremap <F2> :set invpaste paste?<CR>
    set pastetoggle=<F2>
    nnoremap ů ;
    nnoremap ; :
    nmap <s-u> <c-r>
    nmap ž ^
    nmap č $
    nmap <s-k> a<cr><esc>
    nmap <c-down> gj
    nmap <c-up> gk
    nmap <silent>ú :nohlsearch<cr>
    nnoremap <leader>cw *``cgn
    nnoremap <leader>cb #``cgN
    nnoremap <leader>,o <s-a>,<cr><space><bs>
    nnoremap <leader>;o <s-a>;<cr><space><bs>
    nnoremap <leader>o o<space><bs><esc>
    nnoremap <leader><s-o> <s-o><space><bs><esc>
    nnoremap Y y$
    MapSmartKey Home
    MapSmartKey End
    inoremap <> <><Left>
    inoremap () ()<Left>
    inoremap {} {}<Left>
    inoremap [] []<Left>
    inoremap "" ""<Left>
    inoremap '' ''<Left>
    inoremap `` ``<Left>
    nnoremap <leader>b :buffers<CR>:buffer<Space>
    nmap <c-e> :Explore %:p:h<CR>
    " #region K+COC – COC
        inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()
        inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
                                                    " Use tab for trigger completion with characters ahead and navigate.
                                                    " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
                                                    " other plugin before putting this into your config.
        if has('nvim')                                                                  " Use <c-space> to trigger completion.
            inoremap <silent><expr> <c-space> coc#refresh()
        else
            inoremap <silent><expr> <c-@> coc#refresh()
        endif
        inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                                    \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
                                                        " Make <CR> auto-select the first completion item and notify coc.nvim to
                                                        " format on enter, <cr> could be remapped by other vim plugin
        nmap <silent> gd <Plug>(coc-definition)
        nmap <silent> <leader>gdt <Plug>(coc-type-definition)
        nmap <silent> <leader>gdi <Plug>(coc-implementation)
        nmap <silent> <leader>gdr <Plug>(coc-references)
        nmap <silent> [g <Plug>(coc-diagnostic-prev)
        nmap <silent> ]g <Plug>(coc-diagnostic-next)
                        " navigate diagnostics, use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
        nnoremap <silent> gh :call <SID>show_documentation()<CR>
        autocmd CursorHold * silent call CocActionAsync('highlight')
                                                            " Highlight the symbol and its references when holding the cursor.
        nmap <leader><F2> <Plug>(coc-rename)
        xmap <leader>a <Plug>(coc-codeaction-selected)
        nmap <leader>a <Plug>(coc-codeaction-selected)
        nmap <leader>qf  <Plug>(coc-fix-current)
        if has('nvim-0.4.0') || has('patch-8.2.0750')                   " Remap <C-f> and <C-b> for scroll float windows/popups.
            nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
            nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
            inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
            inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
            vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
            vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
        endif
        " Use CTRL-S for selections ranges.
        " Requires 'textDocument/selectionRange' support of language server.
        nmap <silent> <C-s> <Plug>(coc-range-select)
        xmap <silent> <C-s> <Plug>(coc-range-select)
        command! -nargs=0 Format :call CocAction('format')
        command! -nargs=? Fold :call CocAction('fold', <f-args>)
        " Mappings for CoCList
        nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
        nnoremap <silent><nowait> <space>d  :<C-u>CocList diagnostics<cr>
        nnoremap <silent><nowait> <space>r  :<C-u>CocListResume<CR>
        nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
        nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
        nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
        nnoremap <silent><nowait> <F8>      :<C-u>CocNext<CR>
        nnoremap <silent><nowait> <S-F8>    :<C-u>CocPrev<CR>
    " #endregion K+COC – COC
    augroup netrw_mapping
        autocmd!
        autocmd filetype netrw call <sid>NetrwMapping()
    augroup END
    function! s:NetrwMapping()
        nmap <buffer> H u
        nmap <buffer> h -^
        nmap <buffer> <Left> -^
        nmap <buffer> l <CR>
        nmap <buffer> <Right> <CR>
        nmap <buffer> P <C-w><Down>:q<cr>

        nmap <buffer> <leader>% %:w<CR>:buffer #<CR>
        nmap <buffer> <leader>mc mtmc
        nmap <buffer> <leader>mm mtmm
        nmap <buffer> <leader>mf :echo join(netrw#Expose("netrwmarkfilelist"), "\n")<CR>

        nmap <buffer> <leader>r :Ntree<CR>
        nmap <buffer> x :call <sid>NetrwCollapse()<CR>
        nmap <buffer> <c-e> :bd<cr>
    endfunction
"" #endregion Keys
"" #region U – Utils
    function! s:NetrwCollapse()
        redir => cnt
            silent .s/|//gn
        redir END
        let lvl = substitute(cnt, '\n', '', '')[0:0] - 1
        exec '?^\(| \)\{' . lvl . '\}\w'
        exec "normal \<CR>"
    endfunction
    function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
    endfunction
    function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    elseif (coc#rpc#ready())
        call CocActionAsync('doHover')
    else
        execute '!' . &keywordprg . " " . expand('<cword>')
    endif
    endfunction
    function s:SmartHome(mode)
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
    function s:SmartEnd(mode)
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
    "see https://vi.stackexchange.com/a/180
    function! s:CopyRegister()
        let sourceReg = nr2char(getchar())
        if sourceReg !~# '\v^[a-z0-9"]'
            echo "Invalid register given: " . sourceReg
            return
        endif
        let destinationReg = nr2char(getchar())
        if destinationReg !~# '\v^[a-z0-9]'
            echo "Invalid register given: " . destinationReg
            return
        endif
        call setreg(destinationReg, getreg(sourceReg, 1))
        echo "Replaced register '". destinationReg ."' with contents of register '". sourceReg ."'"
    endfunction
"" #endregion U
