#!/usr/bin/bash

cd ~
url_root=https://raw.githubusercontent.com/jaandrle/dotfiles/master
curl $url_root/termux/.vimrc --output ~/.vimrc
curl $url_root/bash/.inputrc --output ~/.inputrc
mkdir ~/.newsboat
curl $url_root/ubuntu/.newsboat/config --output ~/.newsboat/config
curl $url_root/ubuntu/.newsboat/urls --output ~/.newsboat/urls
mkdir ~/bin
ln -s $PREFIX/bin/vim ~/bin/termux-file-editor
# termux-setup-storage
