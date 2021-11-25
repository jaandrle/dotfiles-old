## Vim
My cross-platform config file. Now primarly **Ubuntu**, in the past also Windows (I don't use them so much now → not tested!).

To navigate my secondary editor use [../vscode](../vscode).

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
_vim_plugins --add https://gist.githubusercontent.com/jaandrle/d0ce92e67d03dd8da4b7b932b379b879/raw/b47b1260759d32823890c39df31909f386cc3f6c/vifm.vim
_vim_plugins --add zsugabubus/vim-jumpmotion

mkdir -p ~/.vim/pack/coc/start
cd ~/.vim/pack/coc/start
git clone --branch release https://github.com/neoclide/coc.nvim.git --depth=1
```

#### Native plugins
- [ctrlp.vim ÷ home](http://ctrlpvim.github.io/ctrlp.vim/#installation)
- [vim-highlightedyank: Make the yanked region apparent!](https://github.com/machakann/vim-highlightedyank)
- [mbbill/undotree: The undo history visualizer for VIM](https://github.com/mbbill/undotree)
