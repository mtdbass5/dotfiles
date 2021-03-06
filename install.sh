#!/bin/bash

set -e

mkdir -pv ~/.config/systemd/user \
  ~/.local/share/xorg \

#copy and add systemd user services
if [[ -x systemctl ]]; then
    cp -v systemd/.config/systemd/user/* ~/.config/systemd/user
    for i in ~/.config/systemd/user/*.service; do systemctl --user enable $(basename $i); done;
fi

#create symlinks
stow -v alsa bash cups fonts git gtk i3 mintty mongo mpv mutt redshift rtorrent scripts tmux \
  urlview vim xorg

#install fonts
if [[ -x fc-cache ]]; then
  fc-cache -vf $HOME/.fonts
fi

#install vim colors
if [[ ! -d ~/.vim/colors ]]; then
  mkdir -p ~/.vim/colors
  curl -s -o ~/.vim/colors/smyck.vim https://raw.githubusercontent.com/hukl/Smyck-Color-Scheme/master/smyck.vim
fi

#install vim plugins
if [[ ! -d ~/.vim/bundle ]]; then
  mkdir -p ~/.vim/bundle
  git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall
fi
