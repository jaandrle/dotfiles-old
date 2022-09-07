execute "source ".system("mdexpr-agenda vim 2> /dev/null")
command MDEXPRclose lclose | lexpr []
call scommands#map('m', 'MDEXPR', "n")
