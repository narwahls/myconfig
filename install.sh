#!/bin/sh
## install packages
#awesome awesome-extras rxvt-unicode luakit firefox mpd ncmpcpp git claws-mail 
#claws-mail-il8n puppet? pioneers vlc atool

# to test:
#	http://code.google.com/p/vimwiki/
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
# old/standard zsh config
#rm -rf $HOME/.zshrc; ln -s $CURRENTDIR/.zshrc $HOME/.zshrc

sudo sed -i_bak 's#NoDisplay=true#NoDisplay=false#g' awesome.desktop

rm -rf $HOME/.zshrc; cp $CURRENTDIR/.eh-my-zsh/templastes/zshrc.zsh-template $HOME/.zshrc
sed -i "s#ZSH=\$HOME/.oh-my-zsh#ZSH=$CURRENTDIR/oh-my-zsh#g" $HOME/.zshrc
# set default shell
chsh -s /bin/zsh

