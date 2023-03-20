nmap <leader>vd /diff --git<cr>0vG$
command! AIcommit normal 0r! §ai-commit.mjs
command! AIcommitConventional normal 0r! §ai-commit.mjs --format conventional
command! AIcommitGitmoji normal 0r! §ai-commit.mjs --format gitmoji
nmap <leader><f1> :AIcommitOP
