this_dir=$(dirname $(readlink -f $0))

ln -s $this_dir/.XCompose ~/.XCompose
ln -s $this_dir/.newsboat/config ~/.newsboat/config
ln -s $this_dir/.newsboat/urls ~/.newsboat/urls
ln -s $this_dir/.gitconfig ~/.gitconfig
ln -s $this_dir/uurc ~/.config/uurc
ln -s $this_dir/gh_config.yml ~/.config/gh/config.yml
mkdir ~/bin
ln -s $this_dir/bin/§awk ~/bin/§awk
ln -s $this_dir/bin/§battery ~/bin/§battery
ln -s $this_dir/bin/§calc ~/bin/§calc
ln -s $this_dir/bin/§cordova-release.mjs ~/bin/§cordova-release.mjs
ln -s $this_dir/bin/§extract ~/bin/§extract
ln -s $this_dir/bin/§software ~/bin/§software
ln -s $this_dir/bin/§trans.mjs ~/bin/§trans
ln -s $this_dir/bin/§vim_plugins ~/bin/§vim_plugins
ln -s $this_dir/bin/§vim_cache_clean ~/bin/§vim_cache_clean
ln -s $this_dir/bin/§wallpaper_BIOTD.mjs ~/bin/§wallpaper_BIOTD.mjs
ln -s $this_dir/bin/uu ~/bin/uu
cp -i $this_dir/bin/github-releases.js ~/bin/github-releases.js
cp -i $this_dir/bin/github-releases.json ~/bin/github-releases.json
mkdir ~/.ssh
ln -s $this_dir/.ssh/README.md ~/.ssh/README.md
