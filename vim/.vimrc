""" VIM config file | Jan Andrle | 2021-10-11 (VIM >=8.1)
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
    function! s:AppendModeline(additional)
        let l:modeline= printf(" vim: set tabstop=%d shiftwidth=%d textwidth=%d %sexpandtab :",
            \ &tabstop, &shiftwidth, &textwidth, &expandtab ? '' : 'no')
        let l:modeline= substitute(&commentstring, "%s", l:modeline, "")
        call append(line("$"), l:modeline)
        
        if !a:additional | return 0 | endif
        if &foldmethod=="marker"
            let l:modeline= printf(" vim>60: set foldmethod=marker foldmarker=%s :",
                \ &foldmarker)
        elseif &foldmethod=="indent"
            let l:modeline= printf(" vim>60: set foldmethod=indent foldlevel=%d foldnestmax=%d:",
                \ &foldlevel, &foldnestmax)
        else
            return 0
        endif
        let l:modeline= substitute(&commentstring, "%s", l:modeline, "")
        call append(line("$"), l:modeline)
    endfunction
    command! CLmodelineBasic :call s:AppendModeline(0)
    command! CLmodeline :call s:AppendModeline(1)
    
    nnoremap <leader>t :silent !(exo-open --launch TerminalEmulator > /dev/null 2>&1) &<cr>
"" #endregion B
"" #region I – Intro
    function! CustomIntroPage()
        " Don't run if:
        " - there are commandline arguments;
        " - the buffer isn't empty (e.g. cmd | vi -);
        " - we're not invoked as vim or gvim;
        " - we're starting in insert mode.
        if argc() || line2byte('$') != -1 || v:progname !~? '^[-gmnq]\=vim\=x\=\%[\.exe]$' || &insertmode | return | endif
        enew
        setlocal
            \ bufhidden=wipe
            \ buftype=nofile
            \ nobuflisted
            \ nocursorcolumn
            \ nocursorline
            \ nolist
            \ nonumber
            \ noswapfile
            \ norelativenumber
            \ filetype=markdown
            \ foldmethod=marker
            \ foldmarker=<!--region,<!--endregion-->
        0read ~/.vim/intro-template.md
        /%%VERSION%%
        normal dgn
        call append('.',system('vim --version | head -n 1'))
        normal J$x
        if executable('fortune')
            /%%FORTUNE%%
            normal dgn
            call append('.', map(systemlist('fortune'), '"> " . v:val'))
            normal J
        endif
        :1
        redraw!
        echo "Intro"
        setlocal nomodifiable nomodified
        nnoremap <buffer><silent> e :bd<cr>
        nnoremap <buffer><silent> p :bd<bar>normal "+p<cr>
        nnoremap <buffer><silent> o :browse oldfiles<cr>
        nnoremap <buffer><silent> w :CLsessionLoad<cr>
        nnoremap <buffer><silent> m :marks<cr>
        nnoremap <buffer><silent> y ?## Citát<cr>:nohl<cr>0+ll<c-v>G-$"+ygg
        nnoremap <buffer> P :call <sid>NextFoldClosed('j')<cr>zo
        nnoremap <buffer><silent> c :IntroEdit<cr>
    endfunction
    autocmd VimEnter * call CustomIntroPage()
    command! Intro call CustomIntroPage()
    command! IntroEdit :e ~/.vim/intro-template.md
"" #endregion I
"" #region S – Remap 'sS' (primary s<tab>)
                                                                                                            " use cl/cc
    nmap s <nop>
    vmap s <nop>
    nmap S <nop>
    vmap S <nop>

    nmap sh<leader> :map <leader><cr>
    nmap shs        :map s<cr>
    nmap shT        :map T<cr>
    nmap shh        :call feedkeys(":map! \<c-u\> \| map \<c-up\> \| map \<c-down\>")<cr>
                                                            " s<tab>:   for leverage native Vim command tab competition
                                                            " name your command starting with 'CL'
    nmap s<tab> :call feedkeys(':CL<tab>', 'tn')<cr>
    vmap s<tab> :<c-u>call feedkeys(':CL<tab>', 'tn')<cr>
    nmap S<tab> q:?^CL<cr><cr>
    vmap S<tab> q:?^CL<cr><cr>
    " Set commands …folow the same logic for similar behaviour
    nmap sS :call feedkeys(':Set<tab>', 'tn')<cr>
    nmap SS q:?^Set<cr><cr>
    " ALTernative commands alterbative …folow the same logic for similar behaviour
    nmap sa :call feedkeys(':ALT<tab>', 'tn')<cr>
    nmap Sa q:?^ALT<cr><cr>
"" #endregion S
"" #region H – Helpers
    function s:MapSetToggle(key, opt)
        let cmd = ':set '.a:opt.'! \| set '.a:opt."?\<CR>"
        exec 'nnoremap '.a:key.' '.cmd
        exec 'vnoremap <silent>'.a:key.' <Esc>'.cmd." gv"
        "exec 'inoremap '.a:key." \<C-O>".cmd
    endfunction
    function s:MapSmartKey(key_name)
        let cmd = '<sid>Smart'.a:key_name
        exec 'nmap <silent><'.a:key_name.'> :call '.cmd.'("n")<CR>'
        exec 'imap <silent><'.a:key_name.'> <C-r>='.cmd.'("i")<CR>'
        exec 'vmap <silent><'.a:key_name.'> <Esc>:call '.cmd.'("v")<CR>'
    endfunction
    function! s:ExecuteInShell(command)
        let command = join(map(split(a:command), 'expand(v:val)'))
        let winnr_id = bufwinnr('^' . command . '$')
        silent! execute  winnr_id < 0 ? 'botright new ' . fnameescape(command) : winnr_id . 'wincmd w'
        setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number
        echo 'Execute ' . command . '...'
        silent! execute 'silent %!'. command
        silent! execute 'resize ' . line('$')
        silent! redraw
        silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''
        silent! execute 'nnoremap <silent> <buffer> <LocalLeader>r :call <SID>ExecuteInShell(''' . command . ''')<CR>'
        if line('$')==1 && col('$')==1 | silent! execute 'q' | endif
        echomsg 'Shell command ' . command . ' executed.'
    endfunction
    command! -complete=shellcmd -nargs=+ ALTshell call s:ExecuteInShell(<q-args>)
    function! Grep(...)
        let s:command= join([substitute(&grepprg, ' /dev/null', '', '')] + [expandcmd(join(a:000, ' '))], ' ')
        return system(s:command)
    endfunction
    command! -nargs=+ -complete=file_in_path -bar ALTgrep  cgetexpr Grep(<f-args>)
    command! -nargs=+ -complete=file_in_path -bar ALTlgrep lgetexpr Grep(<f-args>)
    augroup quickfix
        autocmd!
        autocmd QuickFixCmdPost cgetexpr cwindow
                    \| call setqflist([], 'a', {'title': ':' . s:command})
        autocmd QuickFixCmdPost lgetexpr lwindow
                    \| call setloclist(0, [], 'a', {'title': ':' . s:command})
    augroup END
"" #endregion H
"" #region SL – Status Line + Command Line + …
    set showcmd                                                                             " Show size of visual selection
    set cmdheight=2                                                             " Give more space for displaying messages.
    set wildmenu                                                                  " Tab autocomplete in command mode
    set wildmode=list:lastused,list:full
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
    imap <c-u> <c-g>u
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
    set sessionoptions-=options
    let this_session_name="—"
    let this_session_saving=0
    set statusline+=:%{get(g:,'this_session_name','')}\ 
    let sessions_dir= $HOME."/.vim/sessions/"
    if(filewritable(g:sessions_dir) != 2)
        exe 'silent !mkdir -p ' g:sessions_dir
        redraw!
    endif
    function! s:SessionSave(name)
        let b:path= g:sessions_dir.a:name.".vim"
        exe "mksession! ".b:path
        silent execute 'split' b:path
        call append(line('$')-3, "let this_session_name='".a:name."'")
        setlocal bufhidden=delete
        silent update
        silent hide
    endfunction
    function! s:SessionCreate(name)
        let b:swd= input("Session working directory:\n", system('echo $(pwd)'), "file")
        exe "cd ".b:swd
        exe "lcd ".b:swd
        call <sid>SessionSave(a:name)
        echo "\nSession '".a:name."' successfully created."
    endfunction
    function! s:SessionAutosave()
        if g:this_session_name == "—" || g:this_session_saving
            return 0
        endif
        let g:this_session_saving=1
        call <sid>SessionSave(g:this_session_name)
        let g:this_session_saving=0
    endfunction
    autocmd VimLeave,BufWritePost * :call <sid>SessionAutosave()
    command! -nargs=1 SessionCreate :call <sid>SessionCreate(<f-args>)
    command! SessionLoad :call feedkeys(":so ".g:sessions_dir.'<tab>', 'tn')
    command CLsessionLoad :call feedkeys(":so ".g:sessions_dir.'<tab>', 'tn')
    abbreviate CLSL CLsessionLoad
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
    call <sid>MapSetToggle("TN", "relativenumber")
    set foldcolumn=2                                                                   " Add a bit extra margin to the left
    set textwidth=250                                                                                   " Line width marker
    set nowrap                                                                                      " Don't wrap long lines
    set colorcolumn=120,240
    command -nargs=? SetTextWidth if <q-args> | let &textwidth=<q-args> | let &colorcolumn='<args>,120,240' | else | let &textwidth=250 | let &colorcolumn='120,240' | endif
    call <sid>MapSetToggle("TW", "wrap")
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
    call <sid>MapSetToggle("TL", "list")
"" #endregion S
"" #region F – Folds
    set foldmarker=#region,#endregion
    augroup remember_folds
        autocmd!
        autocmd BufWinLeave *.* mkview
        autocmd BufWinEnter *.* silent! loadview
    augroup END
    command!            SetFoldRegions set foldmethod=marker
    abbreviate SFR SetFoldRegions
    command! -nargs=1   SetFoldIndent set foldmethod=indent | let &foldlevel=<q-args> | let &foldnestmax=<q-args>+1
    abbreviate SFI SetFoldIndent
    command! -nargs=*   SetFoldIndents set foldmethod=indent | let &foldlevel=split(<q-args>, ' ')[0] | let &foldnestmax=split(<q-args>, ' ')[1]

    nnoremap <silent> <leader>zJ :call <sid>NextFoldOpen('j')<cr>
    nnoremap <silent> <leader>zj :call <sid>NextFoldClosed('j')<cr>
    nnoremap <silent> <leader>zK :call <sid>NextFoldOpen('k')<cr>
    nnoremap <silent> <leader>zk :call <sid>NextFoldClosed('k')<cr>
    nnoremap <silent> <leader>zn zc:call <sid>NextFoldOpen('j')<cr>
    nnoremap <silent> <leader>zN zc:call <sid>NextFoldOpen('k')<cr>
    function! s:NextFoldClosed(dir)
        let cmd = 'norm!z' . a:dir
        let view = winsaveview()
        let [l0, l, open] = [0, view.lnum, 1]
        while l != l0 && open
            exe cmd
            let [l0, l] = [l, line('.')]
            let open = foldclosed(l) < 0
        endwhile
        if open
            call winrestview(view)
        endif
    endfunction
    function! s:NextFoldOpen(dir)
        let b:step= a:dir=="j" ? 1 : -1
        let b:start = line('.')
        while (foldclosed(b:start) != -1)
            let b:start = b:start + b:step
        endwhile
        call cursor(b:start, 0)
    endfunction
"" #endregion F
"" #region C – Clipboard
    nnoremap <F2> :set invpaste paste?<CR>
    set pastetoggle=<F2>
    nnoremap Y y$
    nnoremap <silent> <leader>" :call <sid>CopyRegister()<cr>
    "see https://vi.stackexchange.com/a/180
    function! s:CopyRegister()
        echo "Copy content of the register: "
        let sourceReg = nr2char(getchar())
        if sourceReg !~# '\v^[a-z0-9"]'
            echon sourceReg." – invalid register"
            return
        endif
        echon sourceReg."\ninto the register: "
        let destinationReg = nr2char(getchar())
        if destinationReg !~# '\v^[a-z0-9]'
            echon destinationReg." – invalid register"
            return
        endif
        call setreg(destinationReg, getreg(sourceReg, 1))
        echon destinationReg
    endfunction
"" #endregion C
"" #region N – Navigation throught Buffers + Windows + … (CtrlP)
    nmap sB :buffers<CR>:b<Space>
    nmap sb :CtrlPBuffer<cr>
    command! BDOthers execute '%bdelete|edit #|normal `"'
    let g:ctrlp_clear_cache_on_exit = 0
    nmap sp :call feedkeys(':CtrlP<tab>', 'tn')<cr>
    nmap Sp q:?^CtrlP<cr><cr>
"" #endregion BW
"" #region FOS – File(s) + Openning + Saving
    set autowrite autoread
    autocmd FocusGained,BufEnter *.* checktime                                                          " …still autoread
    function s:TrimEndLineSpaces(line_start, line_end)
        let b:pos= getpos(".") | let b:s= @/
        execute a:line_start.','.a:line_end.'s/\s\+$//e' | nohl
        let @/= b:s | call setpos('.', b:pos)
    endfunction
    command -bar -nargs=0 -range=% TrimEndLineSpaces call s:TrimEndLineSpaces(<line1>,<line2>)

    command! W w !sudo tee > /dev/null %
                                                                                            " Save a file as root (:W)
    set path+=src/**,app/**,build/**                                                        " File matching for `:find`
    for ignore in [ '.git', '.npm', 'node_modules' ]
        exec ':set wildignore+=**'.ignore.'**'
        exec ':set wildignore+=**/'.ignore.'/**'
    endfor
    set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png,*.ico
    set wildignore+=*.pdf,*.psd

    function! RenameFile()
        let old_name = expand('%')
        let new_name = input('New file name: ', expand('%'), 'file')
        if new_name != '' && new_name != old_name
            exec ':saveas ' . new_name
            exec ':silent !rm ' . old_name
            exec ':silent bd ' . old_file
            redraw!
        endif
    endfunction

    let g:vifm_replace_netrw = 1
    let g:loaded_netrw       = 1
    let g:loaded_netrwPlugin = 1
    nmap <leader>e :Vifm<cr>
    nmap se :call feedkeys(':Vifm<tab>', 'tn')<cr>
"" #endregion FOS
"" #region EN – Editor navigation + search
    " maybe `:help keymap`?
    nmap ž ^
    nmap č $
    nmap <c-down> gj
    nmap <c-up> gk
    call <sid>MapSmartKey("Home")
    call <sid>MapSmartKey("End")
    vnoremap <silent> * :<C-u>call VisualSelection('')<CR>/<C-R>=@/<CR><CR>
    vnoremap <silent> # :<C-u>call VisualSelection('')<CR>?<C-R>=@/<CR><CR>

    set hlsearch                                                                                " Highlight search results
    set ignorecase smartcase infercase                                             " Search queries intelligently set case
    set incsearch                                                                        " Show search results as you type
    nmap <silent>ú :nohlsearch<bar>diffupdate<cr>

    function! VisualSelection(direction) range
        let l:saved_reg = @"
        execute "normal! vgvy"
        let l:pattern = escape(@", "\\/.*'$^~[]")
        let @/ = substitute(l:pattern, "\n$", "", "")
        let @" = l:saved_reg
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

    command CLjumpMotion            call s:GotoJumpChange('jump')
    abbreviate CLJJ CLjumpMotion
    abbreviate CLJM CLjumpMotion
    command CLjumpChanges           call s:GotoJumpChange('change')
    abbreviate CLJC CLjumpChanges
    function! s:GotoJumpChange(cmd)
        let b:key_shotcuts= a:cmd=="jump" ? [ "\<c-i>", "\<c-o>" ] : [ "g,", "g;" ]
        set nomore
        execute a:cmd."s"
        set more
        let j = input("[see help for ':".a:cmd."(s).' | -/+ for up/down]\nselect ".a:cmd.": ")
        if j == '' | return 0 | endif

        let pattern = '\v\c^\+'
        if j =~ pattern
            let j = substitute(j, pattern, '', 'g')
            execute "normal " . j . b:key_shotcuts[0]
        else
            execute "normal " . j . b:key_shotcuts[1]
        endif
    endfunction

    nmap <leader>[I     :call <sid>GotoJumpListDI("[", "I")<cr>
    nmap <leader>]I     :call <sid>GotoJumpListDI("]", "I")<cr>
    nmap <leader>[D     :call <sid>GotoJumpListDI("[", "D")<cr>
    nmap <leader>]D     :call <sid>GotoJumpListDI("]", "D")<cr>
    function! s:GotoJumpListDI(move, key)
        execute "normal ".a:move.a:key
        let c= "<c-".a:key.">"
        let j = input("[see help for ':".tolower(a:key)."list']\nselect '".a:move.c."': ")
        if j == '' | return 0 | endif
        call feedkeys(":call feedkeys(\"".j.a:move."\\".c."\", 'tm')\<cr>")
    endfunction

    command CLjumpListC     call s:GotoJumpListCL('c')
    abbreviate CLJC CLjumpListC
    command CLjumpListL     call s:GotoJumpListCL('l')
    abbreviate CLJL CLjumpListL
    function! s:GotoJumpListCL(name)
        execute a:name."list"
        let j = input("[see help for ':".a:name."list']\nselect '".a:name.a:name."': ")
        if j == '' | return 0 | endif
        execute a:name.a:name." ".j
    endfunction

    nmap sj <Plug>(JumpMotion)
    " https://gist.github.com/romainl/f7e2e506dc4d7827004e4994f1be2df6
    command! -bang -nargs=1 CLjumpSearch call setloclist(0, [], ' ',
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
    nmap TP :call rainbow_parentheses#toggle()<cr>
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
    set shiftwidth=4 tabstop=4 softtabstop=4                                      " Set spaces for tabs everywhere
    command! -nargs=1 SetTab let &shiftwidth=<q-args> | let &tabstop=<q-args> | let &softtabstop=<q-args>
    command! SetSpellToggle set spell!
    set shiftround                                                          " round diff shifts to the base of n*shiftwidth
    set autoindent                                                              " https://stackoverflow.com/a/18415867
    filetype plugin indent on

    nnoremap <leader>cw *``cgn
    nnoremap <leader>cb #``cgN
    nnoremap <leader>,o <s-a>,<cr><space><bs>
    nnoremap <leader>;o <s-a>;<cr><space><bs>
    nnoremap <leader>*o o * <space><bs>
    nnoremap <leader>o o<space><bs><esc>
    nnoremap <leader><s-o> <s-o><space><bs><esc>
    nmap <s-k> a<cr><esc>

    inoremap <> <C-G>u<><Left>
    inoremap () <C-G>u()<Left>
    inoremap {} <C-G>u{}<Left>
    inoremap [] <C-G>u[]<Left>
    inoremap "" <C-G>u""<Left>
    inoremap '' <C-G>u''<Left>
    inoremap `` <C-G>u``<Left>
    
    cnoremap <> <><Left>
    cnoremap () ()<Left>
    cnoremap {} {}<Left>
    cnoremap [] []<Left>
    cnoremap "" ""<Left>
    cnoremap '' ''<Left>
    cnoremap `` ``<Left>

    command SetFFDosToUnix update | edit ++ff=dos | setlocal ff=unix
    
    augroup syntaxSyncMinLines
        autocmd!
        autocmd Syntax * syn sync minlines=2000
    augroup END
"" #endregion EA
"" #region COC – COC, code linting and so on
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
    command! -nargs=? SetFoldCoc :call CocAction('fold', <f-args>)

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
    command CLjumpDefinition        call CocActionAsync('jumpDefinition')
    command CLjumpType              call CocActionAsync('jumpTypeDefinition')
    command CLjumpImplementation    call CocActionAsync('jumpImplementation')
    command CLjumpReferences        call CocActionAsync('jumpReferences')
    command CLextensions            exec 'CocList extensions'
    command CLextensionsMarket      exec 'CocList marketplace'
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
        elseif (coc#rpc#ready())
            call CocActionAsync('doHover')
        else
            execute '!' . &keywordprg . " " . expand('<cword>')
        endif
    endfunction
"" #endregion K+COC – COC

" #region T – TODO
" [iloginow/vim-stylus: A better vim plugin for stylus, including proper and up-to-date syntax highligting, indentation and autocomplete](https://github.com/iloginow/vim-stylus)
" #endregion T

" vim: set tabstop=4 shiftwidth=4 textwidth=250 expandtab :
" vim>60: set foldmethod=marker foldmarker=#region,#endregion :
