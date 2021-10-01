## Vim
My cross-platform (Ubuntu/Windows) config file. Vim isn't my main editor, so I use only Vanilla Vim mainly.

To navigate my primary editor use [../vscode](../vscode).

### Mnemo
1. __"*y__, __"*p__, __"+y__, __"+p__
1. __"\_y__, __"\_p__

### Plugins
```terminal
_vim_plugins --add tpope/vim-repeat
_vim_plugins --add tpope/vim-surround
_vim_plugins --add tpope/vim-liquid
_vim_plugins --add junegunn/rainbow_parentheses.vim
_vim_plugins --add https://gist.githubusercontent.com/jaandrle/9356d737ef5dfda2efbe50248d32cb78/raw/7f73e223b93d9cb889eecc77850604ebe7e102a3/cwordhi.vim
_vim_plugins --add NikolayFrantsev/jshint2.vim

mkdir -p ~/.vim/pack/coc/start
cd ~/.vim/pack/coc/start
git clone --branch release https://github.com/neoclide/coc.nvim.git --depth=1
```
