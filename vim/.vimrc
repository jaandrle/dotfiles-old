""" VIM config file | Jan Andrle | 2022-02-01 (VIM >=8.1)
"" #region B – Base
    scriptencoding utf-8 | set encoding=utf-8
    let $BASH_ENV = "~/.bashrc"
    set runtimepath^=~/.vim/bundle/*
    runtime macros/matchit.vim
    set hidden
    
    set title
    colorscheme codedark
    set updatetime=300 lazyredraw ttyfast   " Having longer updatetime (default is 4s) leads to noticeable delays and poor user experience. Also reduce redraw frequency and fast terminal typing
    set noerrorbells novisualbell
    
    cabbrev <expr> %PWD%  execute('pwd')
    cabbrev <expr> %CD%   fnameescape(expand('%:p:h'))
    cabbrev <expr> %CS%   mini_enhancement#selectedText()
    cabbrev <expr> %CW%   expand('<cword>')
    
    let mapleader = "\\"
    " better for my keyboard, but maybe use `:help keymap`?
    nnoremap § @
    nnoremap §§ @@
    nnoremap ů ;
    nnoremap ; :
    nnoremap <leader>u U
    nnoremap U <c-r>
    nnoremap ž <c-]>
    nnoremap <c-up> <c-y>
    nnoremap <c-down> <c-e>
    " <c-bs>
    imap  <c-w>
    cmap  <c-w>
    
    if executable('konsole')
        command! -nargs=? ALTterminal if <q-args>=='' | execute 'silent !(exo-open --launch TerminalEmulator > /dev/null 2>&1) &' | else | execute 'silent !(konsole -e /bin/bash --rcfile <(echo "source ~/.profile;<args>") > /dev/null 2>&1) &' | endif
    else
        command! -nargs=? ALTterminal silent !(exo-open --launch TerminalEmulator > /dev/null 2>&1) &
    endif
    nnoremap <leader>t :ALTterminal<cr>
    
    if has("patch-8.1.0360")
        set diffopt+=algorithm:patience,indent-heuristic | endif
    set diffopt+=iwhite
    augroup vimrc_help
        autocmd!
        autocmd BufEnter *.txt if &buftype == 'help' | wincmd L | vertical resize 90 | endif
    augroup END
    
    let g:loaded_vimballPlugin = 1 " :h pi_vimball
"" #endregion B
"" #region H – Helpers + remap 'sS' (primary ss, see `vim-scommands`)
    nmap sh :execute 'ALTredir :map s \<bar> map '.mapleader.' \<bar> map § \<bar> map ů \<bar> map ; \<bar> map U \<bar> map ž'<cr>:g/^$/d<cr>:g/^v  s/m$<cr>úgg
    call scommands#map('s', 'CL', "n,v")
    command! -nargs=?  CLscratch 10split | enew | setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted | if <q-args>!='' | execute 'normal "'.<q-args>.'p' | endif | nnoremap <buffer> ;q :q<cr>
    
    call scommands#map('S', 'SET', "n,v")
    function s:SetToggle(option)
        let cmd= ' set '.a:option.'! | set '.a:option.'?' | execute 'command! SETTOGGLE'.a:option.cmd
    endfunction
    
    call scommands#map('a', 'ALT', "n,V")
    cabbrev ALTR ALTredrawSyntax
    set grepprg=LC_ALL=C\ grep\ -nrsH
    command! -nargs=0
        \ ALTredrawSyntax edit | normal `"
    command! -complete=command -bar -range -nargs=+
        \ ALTredir call jaandrle_utils#redir(0, <q-args>, <range>, <line1>, <line2>)
    command! -complete=command -bar -range -nargs=+
        \ ALTredirKeep call jaandrle_utils#redir(1, <q-args>, <range>, <line1>, <line2>)
    command! -nargs=+ -complete=file_in_path -bar
        \ ALTgrep  cgetexpr jaandrle_utils#grep(<f-args>) | call setqflist([], 'a', {'title': ':' . g:jaandrle_utils#last_command})
    command! -nargs=+ -complete=file_in_path -bar
        \ ALTlgrep lgetexpr jaandrle_utils#grep(<f-args>) | call setloclist(0, [], 'a', {'title': ':' . g:jaandrle_utils#last_command})
    
    let g:quickfix_len= 0
    function! QuickFixStatus() abort
        hi! link User1 StatusLine
        if !g:quickfix_len  | return 'Ø' | endif
        if g:quickfix_len>0 | return g:quickfix_len | endif
        let type= &termguicolors ? 'gui' : 'cterm'
        execute 'hi! User1 '.type.'bg='.synIDattr(synIDtrans(hlID('StatusLine')), 'bg').
            \' '.type.'fg='.synIDattr(synIDtrans(hlID('WarningMsg')), 'fg')
        return -g:quickfix_len
    endfunction
    function! s:QuickFixCmdPost() abort
        let q_len= len(getqflist())
        let g:quickfix_len= q_len ? -q_len : len(getloclist(0))
    endfunction
    augroup quickfix
        autocmd!
        autocmd QuickFixCmdPost * call <sid>QuickFixCmdPost()
        autocmd filetype qf
            \  if filter(getwininfo(), {i,v -> v.winnr == winnr()})[0].loclist
            \|      nnoremap <buffer> ;q :lclose<cr>
            \|      nnoremap <buffer> ;w :lgetbuffer<CR>:lclose<CR>:lopen<CR>
            \|      nnoremap <buffer> ;s :ldo s///gc \| update<c-left><c-left><c-left><right><right>
            \| else
            \|      nnoremap <buffer> ;q :cclose<cr>
            \|      nnoremap <buffer> ;w :cgetbuffer<CR>:cclose<CR>:copen<CR>
            \|      nnoremap <buffer> ;s :cdo s///gc \| update<c-left><c-left><c-left><right><right>
            \| endif
    augroup END
"" #endregion H
"" #region SLH – Status Line + Command Line + History (general) + Sessions + File Update, …
    set showcmd cmdheight=2 showmode
    set wildmenu wildmode=list:longest,list:full                                    " Tab autocomplete in command mode
    
    set sessionoptions-=options
    command! -nargs=1
        \ CLSESSIONcreate :call mini_sessions#create(<f-args>)
    command! -nargs=0
        \ CLSESSIONconfig :call mini_sessions#sessionConfig()
    command! -nargs=1 -complete=customlist,mini_sessions#complete
        \ CLSESSIONload :call mini_sessions#load(<f-args>)
    command! -nargs=0
        \ Scd :call mini_sessions#recoverPwd()
    
    execute 'hi! User2 ctermbg='.synIDattr(synIDtrans(hlID('StatusLine')), 'bg').' ctermfg=grey'
    set laststatus=2                                                                     " Show status line on startup
    set statusline+=··%1*≡·%{QuickFixStatus()}%*··%2*»·%{user_tips#current()}%*··%=
    set statusline+=%<%f%R\%M··▶·%{&fileformat}·%{&fileencoding?&fileencoding:&encoding}·%{&filetype}··∷·%{mini_sessions#name('–')}·· 
    
    set history=500                                                   " How many lines of (cmd) history has to remember
    set nobackup nowritebackup noswapfile         " …there is issue #649 (for servers) and I’m using git/system backups
    try
        set undodir=~/.vim/undodir undofile | catch | endtry
    command! CLundotree UndotreeToggle | echo 'Use also :undolist :earlier :later' | UndotreeFocus
    command! SETundoClear let old_undolevels=&undolevels | set undolevels=-1 | exe "normal a \<BS>\<Esc>" | let &undolevels=old_undolevels | unlet old_undolevels | write
"" #endregion SLH
"" #region LLW – Left Column + Line + Wrap + Scrolling
    if has("nvim-0.5.0") || has("patch-8.1.1564")           " Recently vim can merge signcolumn and number column into one
        set signcolumn=number | else | set signcolumn=yes | endif  " show always to prevent shifting when diagnosticappears
    set cursorline                                                                      " Always show current position
    set number foldcolumn=2                               " enable line numbers and add a bit extra margin to the left
    set colorcolumn=+1                                                                                " …marker visual
    command -nargs=? SETtextwidth if <q-args> | let &textwidth=<q-args> | let &colorcolumn='<args>,120,240' | else | let &textwidth=250 | let &colorcolumn='120,240' | endif
    SETtextwidth                                                                    " wraping lines and show two lines
    set nowrap | call <sid>SetToggle('wrap')                                        " Don't wrap long lines by default
    set breakindent breakindentopt=shift:2 showbreak=↳ 
    
    set scrolloff=5 sidescrolloff=10                                        " offset for lines/columns when scrolling
    for l in [ 'r', 'R', 'l', 'L' ]
        exec ':set guioptions-='.l | endfor                        " disable scrollbars
"" #endregion LLW
"" #region CN – Clipboard + Navigation throught Buffers + Windows + … (CtrlP)
    set pastetoggle=<F2> | nnoremap <F2> :set invpaste paste?<CR>
    nnoremap <silent> <leader>" :call jaandrle_utils#copyRegister()<cr>
    
    nmap <expr> š buffer_number("#")==-1 ? "sš<cr>" : "\<c-^>"
    nmap s3 :buffers<cr>:b<space>
    nmap sš :CtrlPBuffer<cr>
    command!            CLcloseOtherBuffers execute '%bdelete|edit #|normal `"'
    command!            ALToldfiles ALTredir oldfiles | call feedkeys(':%s/^\d\+: //<cr>gg:echo ''Alternative to `:browse oldfiles`''', 'tn')
    let g:ctrlp_map = 'ě'
    command! -nargs=?   SETctrlp execute 'nnoremap '.g:ctrlp_map.' :CtrlP <args><cr>'
    call scommands#map(g:ctrlp_map, 'CtrlP', "n")
    let g:ctrlp_clear_cache_on_exit = 0
    let g:ctrlp_prompt_mappings= {
        \ 'ToggleType(1)':        ['<c-up>'],
        \ 'ToggleType(-1)':       ['<c-down>'],
        \ 'PrtCurStart()':        ['<c-b>'],
    \}
"" #endregion CN
"" #region FOS – File(s) + Openning + Saving
    set autowrite autoread | autocmd FocusGained,BufEnter *.* checktime
    command! -bar -nargs=0 -range=%
        \ CLtrimEndLineSpaces call jaandrle_utils#trimEndLineSpaces(<line1>,<line2>)
    set modeline
    command! -nargs=?
        \ CLmodeline :call jaandrle_utils#AppendModeline(<q-args>=='basic' ? 0 : 1)

    set path+=src/**,app/**,build/**                                                        " File matching for `:find`
    for ignore in [ '.git', '.npm', 'node_modules' ]
        exec ':set wildignore+=**'.ignore.'**'
        exec ':set wildignore+=**/'.ignore.'/**'
    endfor
    set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png,*.ico
    set wildignore+=*.pdf,*.psd

    let g:vifm_replace_netrw= 1 | let g:loaded_netrw= 1 | let g:loaded_netrwPlugin= 1  " this line needs to be commented to let vim dowmload spelllangs!!! … see http://jdem.cz/fgyw25
    nmap <leader>e :Vifm<cr>
    call scommands#map('e', 'Vifm', "n")
"" #endregion FOS
"" #region EN – Editor navigation + search
    call jaandrle_utils#MapSmartKey('Home')
    call jaandrle_utils#MapSmartKey('End')

    set hlsearch incsearch                                                        " highlight search, start when typing
    nmap <silent>ú :nohlsearch<bar>diffupdate<cr>

    call scommands#map('n', 'NAV', "n")
    command! NAVjumps call jaandrle_utils#gotoJumpChange('jump')
    command! NAVchanges call jaandrle_utils#gotoJumpChange('change')
    command! NAVmarks call jaandrle_utils#gotoMarks()
"" #endregion EN
"" #region EA – Editing adjustment + White chars + Folds
    " use <c-v>§ for §
    inoremap § <esc>

    let g:markdown_fenced_languages= [ 'javascript', 'js=javascript', 'json', 'html', 'php', 'bash', 'vim', 'vimscript=javascript', 'sass' ]
    " PARENTHESES plugin junegunn/rainbow_parentheses.vim
    let g:rainbow#pairs= [['(', ')'], ['[', ']'], [ '{', '}' ]]
    let g:rainbow#blacklist = [203,9]
    autocmd VimEnter * try
        \| call rainbow_parentheses#toggle() | catch | endtry
    command! SETTOGGLErainbowParentheses call rainbow_parentheses#toggle()
    " HIGHLIGHT&YANK plugins machakann/vim-highlightedyank & cwordhi.vim
    let g:highlightedyank_highlight_duration= 250
    let g:cwordhi#autoload= 1
    set showmatch                                               " Quick highlight oppening bracket/… for currently writted
    set timeoutlen=1000 ttimeoutlen=0                                                  " Remove timeout when hitting escape
    " TAB
    if v:version > 703 || v:version == 703 && has("patch541")
        set formatoptions+=j | endif                            " Delete comment character when joining commented lines
    set expandtab smarttab                                                   " Use spaces instead of tabs and be smart
    call <sid>SetToggle('expandtab')
    command! -nargs=1 SETtab let &shiftwidth=<q-args> | let &tabstop=<q-args> | let &softtabstop=<q-args>
    SETtab 4
    set backspace=indent,eol,start                  " Allow cursor keys in insert mode:  http://vi.stackexchange.com/a/2163
    set shiftround autoindent   " round diff shifts to the base of n*shiftwidth,  https://stackoverflow.com/a/18415867
    filetype plugin indent on
    " SYNTAX&COLORS
    if ($TERM =~ '256' && has("termguicolors"))
        set termguicolors | endif
    if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
        syntax on | endif
    set list listchars=tab:»·,trail:·,extends:#,nbsp:~,space:·      " Highlight spec. chars / Display extra whitespace
    call <sid>SetToggle('list')
    augroup syntax_sync_min_lines
        autocmd!
        autocmd Syntax * syn sync minlines=2000
    augroup END
    " SPELL
    if !has("gui_running")
        hi clear SpellBad | hi SpellBad cterm=underline,italic | endif
    command! -nargs=? SETspell if <q-args>==&spelllang || <q-args>=='' | set spell! | else | set spell | set spelllang=<args> | endif | if &spell | set spelllang | endif
    " EDIT HEPERS
    nnoremap <leader>o o<space><bs><esc>
    nnoremap <leader>O O<space><bs><esc>
    nnoremap <s-k> a<cr><esc>
    for l in [ 'y', 'p', 'P', 'd' ] | for m in [ 'n', 'v' ]
        execute m.'noremap <leader>'.l.' "+'.l | endfor | endfor
    " FOLDS
    command! -nargs=0 SETFOLDregions set foldmethod=marker
    command! -nargs=1 SETFOLDindent set foldmethod=indent | let &foldlevel=<q-args> | let &foldnestmax=<q-args>+1
    command! -nargs=* SETFOLDindents set foldmethod=indent | let &foldlevel=split(<q-args>, ' ')[0] | let &foldnestmax=split(<q-args>, ' ')[1]
    set foldmarker=#region,#endregion
    " SAVE VIEW
    set viewoptions=cursor,folds
    augroup remember__view
        autocmd!
        autocmd BufWinLeave *.* if &buflisted | mkview | endif
        autocmd BufWinEnter *.* silent! loadview
    augroup END
"" #endregion EA
"" #region GIT
    call scommands#map('g', 'GIT', "n,V")
    function s:gitCompletion(_, CmdLine, __)
        let l:cmd= a:CmdLine->split()
        let l:cmd_start= l:cmd[0]
            \ ->substitute('GIThub', 'gh', '')
            \ ->substitute('GIT', 'git ', '')->trim()->split(' ')
        return bash#complete((l:cmd_start+l:cmd[1:])->join())
    endfunction
    function s:gitCmd(candidate)
        let l:main= a:candidate->split()[0]
        let l:pre= ([ 'log' ])->index(l:main)!=-1
                    \ ? 'ALTredirKeep !' : 
                \ ([ 'push', 'pull', 'fetch' ])->index(l:main)!=-1
                    \ ? 'ALTredir !' :
                    \'!clear && echo ":: git '.a:candidate->escape('"').' ::" && '
        execute l:pre.'git '.a:candidate
    endfunction
    function s:githubCmd(type, candidate)
        let l:pre= !a:type
                \ ? '!clear && echo ":: gh '.a:candidate->escape('"').' ::" && ' :
                \ a:type == 1 ? 'ALTredir !' : 'ALTredirKeep !'
        execute l:pre.'gh '.a:candidate
    endfunction
    command! -nargs=* -complete=customlist,<sid>gitCompletion
        \ GIT call <sid>gitCmd(<q-args>)
    command! -nargs=* -complete=customlist,<sid>gitCompletion
        \ GITstatus ALTredirKeep !git status-- <args>
    command! -nargs=* -complete=customlist,<sid>gitCompletion
        \ GITcommit !git commit-- <args>
    command! -nargs=* -complete=customlist,<sid>gitCompletion
        \ GITpush ALTredir !git push <args>
    command! -nargs=* -complete=customlist,<sid>gitCompletion
        \ GITdiff silent! execute 'ALTredirKeep !git diff '.(<q-args>=='' ? '%:p':'<args>')
    command! -nargs=0 -range
        \ GITblameThis ALTredir !git -C %:p:h blame -L <line1>,<line2> %:t
    command! -nargs=*
        \ GITrestore execute '!clear && git status '.(<q-args>=='.' ? '%:p':'<args>').' -bs & git restore '.(<q-args>=='' ? '%:p':'<args>').' --patch'
    command! -count -nargs=* -complete=customlist,<sid>gitCompletion
        \ GIThub call <sid>githubCmd(<count>, <q-args>)
    command! -nargs=? -bang
        \ GIThubIssue execute ( "<bang>"=="!" ? 'ALTredirKeep !' : '!clear &&' ) . 'gh issue view '.expand('<cword>').' '.<q-args>
"" #endregion GIT
"" #region COC – COC and so on, compilers
    let g:coc_global_extensions= [ 'coc-css', 'coc-docthis', 'coc-emmet', 'coc-emoji', 'coc-html', 'coc-json', 'coc-marketplace', 'coc-phpls', 'coc-scssmodules', 'coc-snippets', 'coc-tsserver' ]
    autocmd FileType scss setl iskeyword+=@-@
    command -nargs=? ALTmake if &filetype=='javascript' | compiler jshint | elseif &filetype=='php' | compiler php | endif
                          \| if <q-args>!='' | silent make <args> | else | silent make % | endif | checktime | silent redraw!        " …prev line, hotfix (filetype detection does’t works)
    autocmd BufWritePost *.{php,js,mjs} execute 'ALTmake' | call <sid>QuickFixCmdPost()
    function! CustomKeyWord(word)
        if(a:word=="gulp_place")
            highlight link gulp_place ErrorMsg
            syntax match gulp_place "gulp_place"
            augroup gulp_place
                autocmd!
                autocmd BufEnter *.{js,html} syntax match gulp_place "gulp_place"
            augroup END
            return 0
        endif
    endfunction

    set completeopt=menuone,preview,noinsert,noselect
    inoremap <silent><expr> <F1> pumvisible() ? coc#_select_confirm() : coc#refresh()
    inoremap <silent><expr> <tab> pumvisible() ? "\<c-n>" : <sid>check_back_space() ? "\<tab>" : coc#refresh()
    inoremap <silent><expr> <s-tab> pumvisible() ? "\<c-p>" : "\<c-h>"
    function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    xmap <leader>if <Plug>(coc-funcobj-i)
    omap <leader>if <Plug>(coc-funcobj-i)
    xmap <leader>af <Plug>(coc-funcobj-a)
    omap <leader>af <Plug>(coc-funcobj-a)
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> <leader>gd <Plug>(coc-diagnostic-next)
    nmap <silent> <leader>gD <Plug>(coc-diagnostic-prev)
                    " navigate diagnostics, use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
    nnoremap <silent> gh :call <sid>show_documentation(0)<cr>
    vnoremap <silent> gh :<c-u>call <sid>show_documentation(1)<cr>
    nnoremap <leader>gf :let g:ctrlp_default_input=expand("<cword>") <bar> execute 'CtrlP' <bar> unlet g:ctrlp_default_input <cr>
    vnoremap <leader>gf :<c-u>let g:ctrlp_default_input=mini_enhancement#selectedText() <bar> execute 'CtrlP' <bar> unlet g:ctrlp_default_input <cr>
    autocmd CursorHold * silent call CocActionAsync('highlight')
    """ #region Coc popups scroll (not working for me now, newer version if Vim)
                                                        " Highlight the symbol and its references when holding the cursor.
    if has('nvim-0.4.0') || has('patch-8.2.0750')                   " Remap <C-f> and <C-b> for scroll float windows/popups.
        nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
        nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
        inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
        inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
        vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
        vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
    endif
    """ #endregion Coc popups scroll (not working for me now, newer version if Vim)
    command! -nargs=? SETFOLDcoc :call CocAction('fold', <f-args>)

    call scommands#map('C', 'Coc', "n,v")
    nmap sc :CocList lists<cr>
    nmap Sc :CocListResume<cr>
    nnoremap <c-g> :CLwhereami<cr>
    command! CLwhereami            echo     '"'.expand('%:t').'"'
                                          \ ( coc#status() != "" ? '»'.coc#status().'/'.CocAction("getCurrentFunctionSymbol").'«' : '»«' )
                                          \ line('.').'/'.line('$').'L '.col('.').'/'.col('$').'C'
                                          \ '//'.expand('%:p:h')
    command! CLhelpCocPlug         call feedkeys(':<c-u>help <Plug>(coc	', 'tn')
    command! CLhelpCocAction       call feedkeys(':<c-u>help CocAction(''	', 'tn')
    command! CLrename              call CocActionAsync('rename')
    command! CLrenameFile          exec 'CocCommand workspace.renameCurrentFile'
    command! -nargs=? -bang
           \ CLreplace             call feedkeys(':<c-u>'.(<q-args>==''?'.':<q-args>).'s/'.("<bang>"=='!'?mini_enhancement#selectedText():expand('<cword>')).'//cgODODOD', 'tn')
    command! CLrepeatLastChange    call feedkeys('/\V<C-r>"<CR>cgn<C-a><Esc>', 'tn')
    command! CLjsdoc               exec 'CocCommand docthis.documentThis'
    command! CLcodeactionCursor    call CocActionAsync('codeAction', 'cursor')
    command! CLfixCodeQuick        call CocActionAsync('doQuickfix')
    nnoremap <f1> :CLcheat<cr>
    command! -nargs=?
           \ CLcheat call cheat_copilot#open(<q-args>==''?&filetype:<q-args>)
    command! NAVdefinition         call CocActionAsync('jumpDefinition')
    command! NAVtype               call CocActionAsync('jumpTypeDefinition')
    command! NAVimplementation     call CocActionAsync('jumpImplementation')
    command! NAVreferences         call CocActionAsync('jumpReferences')
    
    nmap <leader>/ :CocSearch 
    nmap <leader>? <leader>/
    
    function! s:show_documentation(is_visual)
        let word= a:is_visual ? getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]-1] : expand('<cword>')
        if (index(['vim','help'], &filetype) >= 0)
            execute 'h '.word
        elseif (index(['git','gitcommit','man'], &filetype) >= 0 || !coc#rpc#ready())
            if &filetype=='man' | let word= "'".word."'" | endif
            execute '!' . &keywordprg . " " . word
        elseif &filetype=='html'
            if coc#source#custom_elements#hover(word)==0
                call CocActionAsync('doHover')
            endif
        else
            call CocActionAsync('doHover')
        endif
    endfunction
"" #endregion COC
" vim: set tabstop=4 shiftwidth=4 textwidth=250 expandtab :
" vim>60: set foldmethod=marker foldmarker=#region,#endregion :
