#!/usr/bin/bash
cd ~
url_root=https://raw.githubusercontent.com/jaandrle/dotfiles/master
curl $url_root/termux/update.sh --output ~/update_new.sh
chmod +x ~/update_new.sh
curl $url_root/termux/.bashrc --output ~/.bashrc

curl $url_root/termux/.vimrc --output ~/.vimrc
curl $url_root/bash/.inputrc --output ~/.inputrc
mkdir ~/.newsboat
curl $url_root/ubuntu/.newsboat/config --output ~/.newsboat/config
curl $url_root/ubuntu/.newsboat/urls --output ~/.newsboat/urls
curl $url_root/ubuntu/.newsboat/html2rss.mjs --output ~/.newsboat/html2rss.mjs
curl $url_root/ubuntu/.newsboat/html2rss-streamCZ.mjs --output ~/.newsboat/html2rss-streamCZ.mjs
curl $url_root/ubuntu/uurc --output ~/.config/uurc
mkdir ~/bin
ln -s $PREFIX/bin/vim ~/bin/termux-file-editor
curl $url_root/ubuntu/bin/pocket-sh-add.sh --output ~/bin/pocket-sh-add.sh
curl $url_root/ubuntu/bin/uu --output ~/bin/uu
mkdir -p ~/.vim/colors
curl $url_root/vim/.vim/colors/codedark.vim --output ~/.vim/colors/codedark.vim

mkdir ~/.termux
echo "extra-keys = [['ESC','~','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]" > ~/.termux/termux.properties
# termux-setup-storage
