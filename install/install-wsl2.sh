#!/bin/bash

sudo apt update
sudo apt upgrade
sudo apt install bat tig pwgen ripgrep ack vim fzf tree silversearcher-ag perl universal-ctags xclip

./backup-bin-scripts.sh
./create-symlinks.sh