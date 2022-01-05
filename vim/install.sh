this_dir=$(dirname $(readlink -f $0))

ln -s $this_dir/.vimrc ~/.vimrc
ln -s $this_dir/.vim/coc-settings.json ~/.vim/coc-settings.json
ln -s $this_dir/.vim/intro-template.md ~/.vim/intro-template.md

ln -s $this_dir/ultisnips ~/.config/coc/ultisnips
