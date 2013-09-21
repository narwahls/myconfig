#!/bin/sh
## install packages
#awesome awesome-extras rxvt-unicode luakit firefox mpd ncmpcpp git claws-mail 
#claws-mail-il8n puppet? pioneers

# create the links for my environment
CURRENTDIR=`pwd -P`
rm $HOME/.Xsession; ln -s $CURRENTDIR/.Xsession $HOME/.Xsession
rm $HOME/.Xresources; ln -s $CURRENTDIR/.Xresources $HOME/.Xresources
rm $HOME/.tmux.conf; ln -s $CURRENTDIR/.tmux.conf $HOME/.tmux.conf
rm $HOME/.vimrc; ln -s $CURRENTDIR/.vimrc $HOME/.vimrc
rm -rf $HOME/.config/awesome; ln -s $CURRENTDIR/awesome $HOME/.config/awesome
rm -rf $HOME/.ncmpcpp; ln -s $CURRENTDIR/ncmpcpp $HOME/.ncmpcpp
rm -rf $HOME/.i3; ln -s $CURRENTDIR/i3 $HOME/.i3

rm -rf $HOME/.vim; ln -s $CURRENTDIR/vim $HOME/.vim
rm -rf $HOME/.zshrc; ln -s $CURRENTDIR/.zshrc $HOME/.zshrc

