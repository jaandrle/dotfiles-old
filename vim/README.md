## Vim
My cross-platform config file. Now primarly **Ubuntu**, in the past also Windows (I don't use them so much now → not tested!).

To navigate my secondary editor use [../vscode](../vscode).

### Plugins
```bash
§vim_plugins --add ctrlpvim/ctrlp.vim
§vim_plugins --add tpope/vim-repeat
§vim_plugins --add tpope/vim-surround
§vim_plugins --add tpope/vim-liquid
§vim_plugins --add junegunn/rainbow_parentheses.vim
§vim_plugins --add chaoren/vim-wordmotion
§vim_plugins --add machakann/vim-highlightedyank
§vim_plugins --add https://gist.githubusercontent.com/jaandrle/9356d737ef5dfda2efbe50248d32cb78/raw/7f73e223b93d9cb889eecc77850604ebe7e102a3/cwordhi.vim
§vim_plugins --add https://gist.githubusercontent.com/jaandrle/d0ce92e67d03dd8da4b7b932b379b879/raw/b47b1260759d32823890c39df31909f386cc3f6c/vifm.vim
§vim_plugins --add rantasub/vim-bash-completion
§vim_plugins --add jaandrle/vim-mini_intro
§vim_plugins --add jaandrle/vim-mini_sessions
§vim_plugins --add jaandrle/vim-jaandrle_utils
§vim_plugins --add jaandrle/vim-mini_enhancement
§vim_plugins --add jaandrle/vim-scommands
§vim_plugins --add jaandrle/vim-user_tips
§vim_plugins --add jaandrle/vim-cheat_copilot
§vim_plugins --add rhysd/git-messenger.vim

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

## To consider
- [vimwiki/vimwiki: Personal Wiki for Vim](https://github.com/vimwiki/vimwiki)
