""" VIM config file | Jan Andrle | 2021-11-25 (VIM >=8.1)
"" #region B – Base
    let $BASH_ENV = "~/.bashrc"
    :scriptencoding utf-8                   " Set internal encoding of vim, not needed on neovim, since coc.nvim using some
    set encoding=utf-8                                                 " unicode characters in the file autoload/float.vim
    set hidden                                                                  " TextEdit might fail if hidden is not set.
    set updatetime=300      " Having longer updatetime (default is 4s) leads to noticeable delays and poor user experience.
    set lazyredraw                                                                          " Reduce the redraw frequency
    set ttyfast                                                                 " Send more characters in fast terminals
    set noerrorbells novisualbell
    set shortmess=
    set title
    colorscheme codedark
    let mapleader = "\\"
    cabbr <expr> %PWD%  execute('pwd')
    cabbr <expr> %CD%   fnameescape(expand('%:p:h'))
    cabbr <expr> %CW%   expand('<cword>')

    nnoremap ů ;
    nnoremap ; :

    function OnVimEnter()
        try
            call rainbow_parentheses#toggle()
        catch
        endtry
    endfunction
    autocmd VimEnter * :call OnVimEnter()

    set runtimepath^=~/.vim/bundle/*
    nmap <leader>gt <c-]>
    nmap <leader>gT <c-T>
    nmap <leader>ga <c-^>
    
    set modeline
    command! CLmodelineBasic :call jaandrle_utils#AppendModeline(0)
    command! CLmodeline :call jaandrle_utils#AppendModeline(1)
    
    nnoremap <leader>t :silent !(exo-open --launch TerminalEmulator > /dev/null 2>&1) &<cr>
"" #endregion B
"" #region S – Remap 'sS' (primary s<tab>)
    nmap sh<leader> :map <leader><cr>
    nmap shh        :call feedkeys(":map! \<c-u\> \| map \<c-up\> \| map \<c-down\>")<cr>
    call scommands#map('<tab>', 'CL', 'n,v')
    call scommands#map('S', 'SET', 'n,v')
    call scommands#map('a', 'ALT', 'n,v')
    call scommands#map('n', 'JUMP', 'n')
"" #endregion S
"" #region H – Helpers
    function s:SetToggle(option)
        let cmd= ' set '.a:option.'! | set '.a:option.'?'
        execute 'command! SETTOGGLE'.a:option.cmd
    endfunction
    command! -complete=command -bar -range -nargs=+ ALTredir call jaandrle_utils#redir(0, <q-args>, <range>, <line1>, <line2>)
    command! -complete=command -bar -range -nargs=+ ALTredirKeep call jaandrle_utils#redir(1, <q-args>, <range>, <line1>, <line2>)
    command! -nargs=+ -complete=file_in_path -bar ALTgrep  cgetexpr jaandrle_utils#grep(<f-args>)
    command! -nargs=+ -complete=file_in_path -bar ALTlgrep lgetexpr jaandrle_utils#grep(<f-args>)
    augroup quickfix
        autocmd!
        autocmd QuickFixCmdPost cgetexpr cwindow
                    \| call setqflist([], 'a', {'title': ':' . g:jaandrle_utils#last_command})
        autocmd QuickFixCmdPost lgetexpr lwindow
                    \| call setloclist(0, [], 'a', {'title': ':' . g:jaandrle_utils#last_command})
    augroup END
"" #endregion H
"" #region SL – Status Line + Command Line + …
    set showcmd                                                                             " Show size of visual selection
    set cmdheight=2                                                             " Give more space for displaying messages.
    set wildmenu                                                                  " Tab autocomplete in command mode
    set wildmode=list:longest,list:lastused,list:full
    set showmode
    set laststatus=2                                                                           " Show status line on startup
    let g:statusline_echo= ''
    function! SLE(msg)
        let g:statusline_echo= a:msg!='' ? ' ' : ''
        let g:statusline_echo.= a:msg
    endfunction
    set statusline+=%{get(g:,'statusline_echo','\ ')}
    set statusline+=%{coc#status()}\ %{get(b:,'coc_current_function','')}\ 
    set statusline+=\ %c:%l\/%L\ 
    set statusline+=%=
    set statusline+=%<%F
    set statusline+=%R\%M\ 
    set statusline+=%{&fileformat}
    set statusline+=·%{&fileencoding?&fileencoding:&encoding}
    set statusline+=·%{&filetype}\ 
"" #endregion SL
"" #region HS – History (general) + Sessions + File Update
    nmap <s-u> <c-r>
    set nobackup nowritebackup                                      " Some servers have issues with backup files, see #649.
                                                                    " Return to last edit position when opening files (You want this!)
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    set nobackup nowritebackup noswapfile                                                       " Turn off backup files
    set history=500                                                         " How many lines of history has to remember
                                                                                 " Savig edit history for next oppening
    try
        set undodir=~/.vim/undodir
        set undofile
    catch
    endtry
    set statusline+=:%{get(g:,'this_session_name','')}\ 
    command! -nargs=1 CLSESSIONCreate :call mini_sessions#create(<f-args>)
    command CLSESSIONload :call mini_sessions#open()
    command CLundotree UndotreeToggle | echo 'Use also :undolist :earlier :later'
"" #endregion HS
"" #region LLW – Left Column + Line + Wrap
    if has("nvim-0.5.0") || has("patch-8.1.1564")           " Recently vim can merge signcolumn and number column into one
        set signcolumn=number
    else
        set signcolumn=yes
    endif      " Always show the signcolumn, otherwise it would shift the text each time diagnostics appear/become resolved.
    set cursorline                                                                        " Always show current position
    set ruler
    set colorcolumn=+1                                                                                  " …marker visual
    set number                                                                                        " Enable line numbers
    call <sid>SetToggle('relativenumber')
    set foldcolumn=2                                                                   " Add a bit extra margin to the left
    set textwidth=250                                                                                   " Line width marker
    set nowrap                                                                                      " Don't wrap long lines
    set colorcolumn=120,240
    command -nargs=? SETtextwidth if <q-args> | let &textwidth=<q-args> | let &colorcolumn='<args>,120,240' | else | let &textwidth=250 | let &colorcolumn='120,240' | endif
    call <sid>SetToggle('wrap')
    set breakindent
    set breakindentopt=shift:2
    set showbreak=↳ 
"" #endregion LLW
"" #region SW – Scrolling + White chars
    set scrolloff=5                                                                  " Leave lines of buffer when scrolling
    set sidescrolloff=10                                             " Leave characters of horizontal buffer when scrolling
    for l in [ 'r', 'R', 'l', 'L' ]                " Disable scrollbars (real hackers don't use scrollbars for navigation!)
        exec ':set guioptions-='.l
    endfor
    set list                                                            " Highlight spec. chars / Display extra whitespace
    set listchars=tab:»·,trail:·,extends:#,nbsp:~,space:·
    call <sid>SetToggle('list')
"" #endregion S
"" #region F – Folds
    set foldmarker=#region,#endregion
    augroup remember_folds
        autocmd!
        autocmd BufWinLeave *.* mkview
        autocmd BufWinEnter *.* silent! loadview
    augroup END
    command!            SETFOLDregions set foldmethod=marker
    command! -nargs=1   SETFOLDindent set foldmethod=indent | let &foldlevel=<q-args> | let &foldnestmax=<q-args>+1
    command! -nargs=*   SETFOLDindents set foldmethod=indent | let &foldlevel=split(<q-args>, ' ')[0] | let &foldnestmax=split(<q-args>, ' ')[1]

    nnoremap <silent> <leader>zJ :call jaandrle_utils#fold_nextOpen('j')<cr>
    nnoremap <silent> <leader>zj :call jaandrle_utils#fold_nextClosed('j')<cr>
    nnoremap <silent> <leader>zK :call jaandrle_utils#fold_nextOpen('k')<cr>
    nnoremap <silent> <leader>zk :call jaandrle_utils#fold_nextClosed('k')<cr>
    nnoremap <silent> <leader>zn zc:call jaandrle_utils#fold_nextOpen('j')<cr>
    nnoremap <silent> <leader>zN zc:call jaandrle_utils#fold_nextOpen('k')<cr>
"" #endregion F
"" #region C – Clipboard
    nnoremap <F2> :set invpaste paste?<CR>
    set pastetoggle=<F2>
    nnoremap <silent> <leader>" :call jaandrle_utils#copyRegister()<cr>
"" #endregion C
"" #region N – Navigation throught Buffers + Windows + … (CtrlP)
    nmap sB :buffers<CR>:b<Space>
    call scommands#map('b', 'CtrlPBuffer', 'n')
    command! BDOthers execute '%bdelete|edit #|normal `"'
    let g:ctrlp_clear_cache_on_exit = 0
    call scommands#map('p', 'CtrlP', 'n')
"" #endregion BW
"" #region FOS – File(s) + Openning + Saving
    set autowrite autoread
    autocmd FocusGained,BufEnter *.* checktime                                                          " …still autoread
    command -bar -nargs=0 -range=% CLtrimEndLineSpaces call jaandrle_utils#trimEndLineSpaces(<line1>,<line2>)

    command! W w !sudo tee > /dev/null %
                                                                                            " Save a file as root (:W)
    set path+=src/**,app/**,build/**                                                        " File matching for `:find`
    for ignore in [ '.git', '.npm', 'node_modules' ]
        exec ':set wildignore+=**'.ignore.'**'
        exec ':set wildignore+=**/'.ignore.'/**'
    endfor
    set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png,*.ico
    set wildignore+=*.pdf,*.psd

    let g:vifm_replace_netrw = 1
    let g:loaded_netrw       = 1
    let g:loaded_netrwPlugin = 1
    nmap <leader>e :Vifm<cr>
    call scommands#map('e', 'Vifm', 'n')
"" #endregion FOS
"" #region EN – Editor navigation + search
    " maybe `:help keymap`?
    nmap ž ^
    nmap č $
    nmap <c-down> gj
    nmap <c-up> gk
    call jaandrle_utils#MapSmartKey('Home')
    call jaandrle_utils#MapSmartKey('End')

    set hlsearch                                                                                " Highlight search results
    set ignorecase smartcase infercase                                             " Search queries intelligently set case
    set incsearch                                                                        " Show search results as you type
    nmap <silent>ú :nohlsearch<bar>diffupdate<cr>

    command JUMPmotion            call jaandrle_utils#gotoJumpChange('jump')
    command JUMPchanges           call jaandrle_utils#gotoJumpChange('change')
    command JUMPlistC     call jaandrle_utils#gotoJumpListCL('c')
    command JUMPlistL     call jaandrle_utils#gotoJumpListCL('l')

    nmap <leader>[I     :call jaandrle_utils#gotoJumpListDI("[", "I")<cr>
    nmap <leader>]I     :call jaandrle_utils#gotoJumpListDI("]", "I")<cr>
    nmap <leader>[D     :call jaandrle_utils#gotoJumpListDI("[", "D")<cr>
    nmap <leader>]D     :call jaandrle_utils#gotoJumpListDI("]", "D")<cr>

    nmap sj <Plug>(JumpMotion)
    " https://gist.github.com/romainl/f7e2e506dc4d7827004e4994f1be2df6
    command! -bang -nargs=1 JUMPsearch call setloclist(0, [], ' ',
        \ {'title': 'Global ' .. <q-args>,
        \  'efm':   '%f:%l\ %m,%f:%l',
        \  'lines': execute('g<bang>/' .. <q-args> .. '/#')
        \           ->split('\n')
        \           ->map({_, val -> expand("%") .. ":" .. trim(val, 1)})
        \ })
"" #endregion EN
"" #region EA – Editing adjustment
    let g:highlightedyank_highlight_duration= 250
    set showmatch                                               " Quick highlight oppening bracket/… for currently writted
    command! SETTOGGLErainbowParentheses call rainbow_parentheses#toggle()
    let g:rainbow#pairs = [['(', ')'], ['[', ']'], [ '{', '}' ]]
    set timeoutlen=1000 ttimeoutlen=0                                                  " Remove timeout when hitting escape
    set completeopt=menuone,preview,noinsert,noselect
    set backspace=indent,eol,start                  " Allow cursor keys in insert mode:  http://vi.stackexchange.com/a/2163
    let g:cwordhi#autoload= 1
                                                    " Switch syntax highlighting on, when the terminal has colors. Also switch on highlighting the last used search pattern.
    if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
      syntax on
    endif
    if v:version > 703 || v:version == 703 && has("patch541")
      set formatoptions+=j " Delete comment character when joining commented lines
    endif
    set expandtab smarttab                                                        " Use spaces instead of tabs and be smart
    call <sid>SetToggle('expandtab')
    command! -nargs=1 SETtab let &shiftwidth=<q-args> | let &tabstop=<q-args> | let &softtabstop=<q-args>
    SETtab 4
    command! SETTOGGLEspell set spell! | if &spell | set spelllang | endif
    set shiftround                                                          " round diff shifts to the base of n*shiftwidth
    set autoindent                                                              " https://stackoverflow.com/a/18415867
    filetype plugin indent on

    nnoremap <s-k> a<cr><esc>
    nnoremap <leader>cw *``cgn
    nnoremap <leader>cb #``cgN
    nnoremap <leader>,o <s-a>,<cr><space><bs>
    nnoremap <leader>;o <s-a>;<cr><space><bs>
    nnoremap <leader>*o o * <space><bs>
    nnoremap <leader>o o<space><bs><esc>
    nnoremap <leader><s-o> <s-o><space><bs><esc>
    augroup syntaxSyncMinLines
        autocmd!
        autocmd Syntax * syn sync minlines=2000
    augroup END
    if !has("gui_running")
        hi clear SpellBad
        hi SpellBad cterm=underline,italic
    endif
    command SETfileformatDOS2UNIX update | edit ++ff=dos | setlocal ff=unix
"" #endregion EA
"" #region COC – COC, code linting, git and so on
    call scommands#map('g', 'GIT', 'n')
    command GITstatus silent! execute 'ALTredirKeep !git status && echo && echo Commits unpushed: && git log @{push}..HEAD && echo'
        \| setlocal filetype=git
        \| $normal oTips: You can use `gf` to navigate into files. Also `;e` for reload or `;q` for `:bd`.
    command -nargs=? GITcommit !clear && git status & git commit --interactive -v <args>
    command GITrestoreThis !git status %:p -s & git restore %:p --patch
    command GITlog silent! execute 'ALTredirKeep !git log --date=iso' | setlocal filetype=git
    command GITlogList !git log-list
    command -nargs=? GITfetch ALTredir !git fetch <args>
    command -nargs=? GITpull ALTredir !git pull <args>
    command -nargs=? GITpush ALTredir !git push <args>
    command -nargs=? GITonlyCommit !git commit -v <args>
    command -nargs=? GITonlyAdd !git status & git add -i <args>
    augroup JSLinting
        autocmd!
        autocmd FileType javascript compiler jshint
        autocmd QuickFixCmdPost [^l]* cwindow
    augroup END
    command ALTmake silent make | checktime | silent redraw!

    let g:coc_global_extensions= [
        \ 'coc-css',
        \ 'coc-docthis',
        \ 'coc-emmet',
        \ 'coc-emoji',
        \ 'coc-html',
        \ 'coc-json',
        \ 'coc-marketplace',
        \ 'coc-phpls',
        \ 'coc-scssmodules',
        \ 'coc-snippets',
        \ 'coc-tsserver'
    \]

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
    nmap <silent> <leader>gd <Plug>(coc-diagnostic-next)
    nmap <silent> <leader>gD <Plug>(coc-diagnostic-prev)
                    " navigate diagnostics, use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
    nnoremap <silent> gh :call <SID>show_documentation()<CR>
    autocmd CursorHold * silent call CocActionAsync('highlight')
                                                        " Highlight the symbol and its references when holding the cursor.
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
    command! -nargs=? SETFOLDcoc :call CocAction('fold', <f-args>)

    command CLdocumentation         call <sid>show_documentation()
    command CLoutline               exec 'CocList outline'
    command CLsymbols               exec 'CocList -I symbols'
    command CLdiagnostics           exec 'CocList diagnostics'
    command CLcmdCoc                exec 'CocList commands'
    command CLrename                call CocActionAsync('rename')
    command CLrenameFile            exec 'CocCommand workspace.renameCurrentFile'
    command CLjsdoc                 exec 'CocCommand docthis.documentThis'
    command CLcodeactionCursor      call CocActionAsync('codeAction', 'cursor')
    command CLfixCodeQuick          call CocActionAsync('doQuickfix')
    command CLextensions            exec 'CocList extensions'
    command CLextensionsMarket      exec 'CocList marketplace'
    command JUMPdefinition        call CocActionAsync('jumpDefinition')
    command JUMPtype              call CocActionAsync('jumpTypeDefinition')
    command JUMPimplementation    call CocActionAsync('jumpImplementation')
    command JUMPreferences        call CocActionAsync('jumpReferences')
    nnoremap <F8>      :<C-u>CocNext<CR>
    nnoremap [19;2~  :<C-u>CocPrev<CR>
    
    nmap s<s-tab> :call feedkeys(':Coc<tab>', 'tn')<cr>
    nmap S<s-tab> :CocListResume<cr>
    nmap <leader>/ :CocSearch 
    nmap <leader>? <leader>/
    
    function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
    endfunction
    function! s:show_documentation()
        if (index(['vim','help'], &filetype) >= 0)
            execute 'h '.expand('<cword>')
        elseif (index(['git'], &filetype) >= 0 || !coc#rpc#ready())
            execute '!' . &keywordprg . " " . expand('<cword>')
        else
            call CocActionAsync('doHover')
        endif
    endfunction
"" #endregion COC

" #region T – TODO
" [iloginow/vim-stylus: A better vim plugin for stylus, including proper and up-to-date syntax highligting, indentation and autocomplete](https://github.com/iloginow/vim-stylus)
" #endregion T

" vim: set tabstop=4 shiftwidth=4 textwidth=250 expandtab :
" vim>60: set foldmethod=marker foldmarker=#region,#endregion :
