#!/bin/bash

echo 'WARNING! INSTALL.SH IS A DESTRUCTIVE OPERATION!
It will remove files like ~/.vimrc before symlinking them to this directory.

Are you sure you want to contine? (y/n)'
read -r response
if [[ "$response" != "y" && "$response" != "Y" ]]; then
  echo "Install.sh exited without making changes."
  exit
fi

echo
DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

echo "Linking ~/.vimrc"
rm -f $HOME/.vimrc
ln -s $DIR/.rc/.vimrc $HOME/.vimrc

echo "Linking ~/.vim"
sudo rm -rf $HOME/.vim
ln -s $DIR/.vim $HOME/.vim

echo "Linking ~/.bashrc"
sudo rm -rf $HOME/.bashrc
ln -s $DIR/.rc/.bashrc $HOME/.bashrc

echo "Linking ~/.profile"
sudo rm -rf $HOME/.profile
ln -s $DIR/.rc/.profile $HOME/.profile


echo "Linking ~/bin/{sub_dirs}"
for SUB_DIR in $DIR/bin/*/; do
  sudo rm -rf $HOME/bin/$SUB_DIR
  ln -s $DIR/bin/$SUB_DIR $HOME/bin/$SUB_DIR
done
export PATH
