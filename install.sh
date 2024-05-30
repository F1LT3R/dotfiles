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
BASE=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

echo "Linking ~/.vimrc"
rm -f $HOME/.vimrc
ln -s $BASE/.rc/.vimrc $HOME/.vimrc

echo "Linking ~/.vim"
sudo rm -rf $HOME/.vim
ln -s $BASE/.vim $HOME/.vim

echo "Linking ~/.bashrc"
sudo rm -rf $HOME/.bashrc
ln -s $BASE/.rc/.bashrc $HOME/.bashrc

echo "Linking ~/.profile"
sudo rm -rf $HOME/.profile
ln -s $BASE/.rc/.profile $HOME/.profile

mkdir -p ~/bin
cd bin
for DIR in *; do
    echo "Linking ~/bin/$DIR"
    rm -f $HOME/bin/$DIR
    ln -sf $BASE/bin/$DIR $HOME/bin/$DIR
done
