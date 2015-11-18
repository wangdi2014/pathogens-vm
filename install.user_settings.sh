#!/usr/bin/env bash
set -e

gconftool-2 --set "/apps/gnome-terminal/profiles/Default/foreground_color" --type string "#EEEEEEEEEEEE"
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/background_color" --type string "#000000000000"

# green prompt
echo 'export PS1="\[\e[00;32m\]\u@\h:\w\\$\[\e[0m\]\[\e[00;37m\] \[\e[0m\]"' >> $HOME/.bashrc

# desktop background
cp desktop_background_sanger.jpg ~/Pictures/
chmod 644 ~/Pictures/desktop_background_sanger.jpg
gsettings set org.gnome.desktop.background picture-uri file:///home/manager/Pictures/desktop_background_sanger.jpg

# Set up a bin directory
mkdir ~/bin
echo 'export PATH=$HOME/bin/:$PATH' >> ~/.bashrc
