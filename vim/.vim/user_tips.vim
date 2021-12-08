let g:user_tips_list= [
    \ ":clist+:cc :cn :cN :copen :cwindow :cclose",
    \ ":undolist :earlier :later",
    \ ":llist+:ll :ln :lN :lopen :lwindow :lclose",
    \ "QuickList → :set modifiable+‘edit’+;w ;s … ;q",
    \ "Buffer info → <c-g> g<c-g>",
    \ "Rename file → :saveas * | :silent !rm # | :bw #",
    \ "Next word location → ]I [I ]<c-I> [<c-I> … <leader>]I <leader>[I",
    \ ":!sudo tee > /dev/null %",
    \ ":ilist pattern … :ijump pattern",
    \ ":*fold<tab> :diff*<tab> :map <buffer><tab>",
    \ "Macro defs. → ]D [D ]<c-D> [<c-D> … :dlist string … :djump string",
    \ ":update | edit ++ff=dos | setlocal ff=unix",
    \ ":set spell :spell<tab> z=",
    \ ":lhistory :lolder :lnewer",
    \ "*grep onchange -r . --include=*.\{js,md\} …or http://jdem.cz/fgytv8",
    \ ":diffget :diffput c] [c",
    \ ":chistory :colder :cnewer"
  \ ]
