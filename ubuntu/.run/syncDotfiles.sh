#!/bin/bash
github_dotfiles="$HOME/Dokumenty/GitHub/dotfiles"

echo :::    syncDotfiles.sh \(jaandrle\)   :::
echo \    This script helps me to keep my dot files up to date.
echo Usage:
echo \    \`syncDotfiles [area cmd]\`:
echo \    - area: vim\|vifm\|bash\|run elsewhere help
echo \    - cmd: in fact argument for \`eval\` with \`::github::\`, \`::linux::\` placeholders
echo Info:
echo \    Current git location: $github_dotfiles

count=0
function run(){
    if [ $count -eq 0 ]; then
        count=1
        echo Results:
        echo
    fi
    local cmd=${1/::github::/$2}
    local cmd=${cmd/::linux::/$3}
    eval "$cmd"
    return
}

case "$1" in
    vim)
        gv="$github_dotfiles/vim"
        run "$2" "$gv/.vimrc" "$HOME/.vimrc"
        ;;
    vifm)
        gv="$github_dotfiles/vifm"
        run "$2" "$gv/vifmrc" "$HOME/.vifm/vifmrc"
        ;;
    bash)
        gv="$github_dotfiles/bash"
        run "$2" "$gv/.bashrc" "$HOME/.bashrc"
        run "$2" "$gv/.inputrc" "$HOME/.inputrc"
        ;;
    run)
        gv="$github_dotfiles/ubuntu"
        run "$2" "$gv/.run" "$HOME/.run"
        ;;
    *)
        echo Some examples:
        echo \    - .run/syncDotfiles.sh run \"diff -qs ::github:: ::linux::\"
        echo \    - .run/syncDotfiles.sh bash \"meld ::github:: ::linux::\"
        echo \    - .run/syncDotfiles.sh run \'diff -q ::github:: ::linux::\' \| awk \'END {split\(\$0,a,\" \"\)\; print a[2]\" \" a[4]}\' \| xargs meld
esac

