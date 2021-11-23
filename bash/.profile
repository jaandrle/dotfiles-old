# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

export APPMENU_DISPLAY_BOTH=1
if [ -n "$GTK_MODULES" ]
then
  GTK_MODULES="$GTK_MODULES:unity-gtk-module"
else
  GTK_MODULES="unity-gtk-module"
fi

if [ -z "$UBUNTU_MENUPROXY" ]
then
  UBUNTU_MENUPROXY=1
fi

export GTK_MODULES
export UBUNTU_MENUPROXY

export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/"

# Ubuntu make installation of Ubuntu Make binary symlink
PATH=/home/jaandrle/.local/share/umake/bin:$PATH

# Ubuntu make installation of Android Studio
export ANDROID_HOME=/home/jaandrle/.local/share/umake/android/android-studio

[ -f /home/jaandrle/.bash/.profile_androidsdk ] && . /home/jaandrle/.bash/.profile_androidsdk
