this_dir=$(dirname $(readlink -f $0))

ln -s $this_dir/.bashrc ~/.bashrc
ln -s $this_dir/.profile ~/.profile
ln -s $this_dir/.inputrc ~/.inputrc
mkdir ~/.bash
ln -s $this_dir/.bash/.bash_aliases ~/.bash/.bash_aliases
ln -s $this_dir/.bash/.bash_completions ~/.bash/.bash_completions
ln -s $this_dir/.bash/cordova.completion ~/.bash/cordova.completion
ln -s $this_dir/.bash/.bash_jaaENV ~/.bash/.bash_jaaENV
ln -s $this_dir/.bash/.bash_nvm ~/.bash/.bash_nvm
ln -s $this_dir/.bash/.bash_promt ~/.bash/.bash_promt
ln -s $this_dir/.bash/.bash_sdkman ~/.bash/.bash_sdkman
ln -s $this_dir/.bash/.profile_androidsdk ~/.bash/.profile_androidsdk
