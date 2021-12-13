let g:user_tips_list= [
    \ ':clist+:cc :cn :cN :copen :cwindow :cclose',
    \ ':undolist :earlier :later',
    \ ':llist+:ll :ln :lN :lopen :lwindow :lclose',
    \ 'QuickList → :set ma+‘edit’+;w ;s … ;q',
    \ 'Buffer info → <c-g> g<c-g> … :map <buffer><tab>',
    \ 'Rename file → :saveas * | :silent !rm # | :bw #',
    \ 'Next word location → ]I [I ]<c-I> [<c-I> … <leader>]I <leader>[I',
    \ ':w !sudo tee > /dev/null %',
    \ '`0·`\"·`.·`` … last exit·edit·change·pre-jump',
    \ 'q: q? q/ … @: ?<cr> /<cr> :&<cr> , ;',
    \ '<c-n><c-p> <c-x><c-l> <c-x><c-f> … :h ins-completion',
    \ ':set nowrapscan (cycle search)',
    \ '<c-x>= <c-v>',
    \ 'silent! %s/[\\r \\t]\+$//',
    \ ':ilist pattern … :ijump pattern',
    \ 'Replace mode → R',
    \ 'J gJ K gwip g~ ~',
    \ 'Folds → zm za zi (zfG) zc zC zo zO … :*fold<tab>',
    \ 'Macro defs. → ]D [D ]<c-D> [<c-D> … :dlist string … :djump string',
    \ ':update | edit ++ff=dos | setlocal ff=unix',
    \ ':set scrollbind :diffthis :diffoff :diff*<tab>',
    \ ":let i=10 | 'a,'bg/Abc/s/yy/\=i/ |let i=i+1 # convert yy to 10,11,12 etc",
    \ 'v_* :%s//replacement',
    \ ':5,10norm! @a … :g/pattern/norm! @a',
    \ '`textwidth` → n_gq* v_gq',
    \ 'File encryption → :X … vim -x filename',
    \ ':sort /,/',
    \ 'zz zb zt gm gM',
    \ '<c-a> <c-x> g<c-a>…',
    \ ':set spell :spell<tab> … z= ]s [s',
    \ ':lhistory :lolder :lnewer',
    \ ':[m]ove :[c]opy (:t) :p :#',
    \ ':help i_CTRL-<tab> … i_CTRL-Y',
    \ '*grep onchange -r . --include=*.\{js,md\} …or http://jdem.cz/fgytv8',
    \ ':diffget :diffput c] [c',
    \ ':chistory :colder :cnewer',
    \ 'Repeat substitution(s) & g& :& :&& :~ … :help :s_flags'
  \ ]