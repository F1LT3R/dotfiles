#!/bin/bash

PS3='
Please select your OS: '
options=("Ubuntu Native" "WSL2 Ubuntu" "Termux")
echo

select opt in "${options[@]}"
do
    case $opt in
        "Ubuntu Native")
            echo
            echo "Installing Dotfiles for $opt..."
            echo
            ./install/install-ubuntu.sh
            break
            ;;
        "WSL2 Ubuntu")
            echo
            echo "Installing Dotfiles for $opt..."
            echo
            ./install/install-wsl2.sh
            break
            ;;
        "Termux")
            echo
            echo "Installing Dotfiles for $opt..."
            echo
            ./install/install-wsl2.sh
            break
            ;;
        *) echo "Invalid option $REPLY";;
    esac
done