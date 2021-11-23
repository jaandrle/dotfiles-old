this_dir=$(dirname $(readlink -f $0))

ln -s $this_dir/.XCompose ~/.XCompose
mkdir ~/bin
ln -s $this_dir/bin/_awk ~/bin/_awk
ln -s $this_dir/bin/_calc ~/bin/_calc
ln -s $this_dir/bin/_cordova-release.mjs ~/bin/_cordova-release.mjs
ln -s $this_dir/bin/_extract ~/bin/_extract
ln -s $this_dir/bin/_vim_plugins ~/bin/_vim_plugins
ln -s $this_dir/bin/_weather ~/bin/_weather
ln -s $this_dir/bin/github-releases.js ~/bin/github-releases.js
cp -i $this_dir/bin/github-releases.json ~/bin/github-releases.json