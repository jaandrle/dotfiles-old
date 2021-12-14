## Vim
My cross-platform config file. Now primarly **Ubuntu**, in the past also Windows (I don't use them so much now → not tested!).

To navigate my secondary editor use [../vscode](../vscode).

### Mnemo
1. __"*y__, __"*p__, __"+y__, __"+p__
1. __"\_y__, __"\_p__

### Plugins
```terminal
_vim_plugins --add ctrlpvim/ctrlp.vim
_vim_plugins --add tpope/vim-repeat
_vim_plugins --add tpope/vim-surround
_vim_plugins --add tpope/vim-liquid
_vim_plugins --add junegunn/rainbow_parentheses.vim
_vim_plugins --add machakann/vim-highlightedyank
_vim_plugins --add https://gist.githubusercontent.com/jaandrle/9356d737ef5dfda2efbe50248d32cb78/raw/7f73e223b93d9cb889eecc77850604ebe7e102a3/cwordhi.vim
_vim_plugins --add https://gist.githubusercontent.com/jaandrle/d0ce92e67d03dd8da4b7b932b379b879/raw/b47b1260759d32823890c39df31909f386cc3f6c/vifm.vim
_vim_plugins --add zsugabubus/vim-jumpmotion
_vim_plugins --add jaandrle/vim-mini_intro
_vim_plugins --add jaandrle/vim-mini_sessions
_vim_plugins --add jaandrle/vim-jaandrle_utils
_vim_plugins --add jaandrle/vim-mini_enhancement
_vim_plugins --add jaandrle/vim-scommands
_vim_plugins --add jaandrle/vim-user_tips

mkdir -p ~/.vim/pack/coc/start
cd ~/.vim/pack/coc/start
git clone --branch release https://github.com/neoclide/coc.nvim.git --depth=1

mkdir -p ~/.vim/pack/coc-custom_elements/start
cd ~/.vim/pack/coc-custom_elements/start
git clone https://github.com/jaandrle/coc-custom_elements
```
Also call `:helptags ~/.vim/bundle/`.

#### Native plugins
- [mbbill/undotree: The undo history visualizer for VIM](https://github.com/mbbill/undotree)
