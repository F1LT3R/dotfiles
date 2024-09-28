#!/bin/bash

source ./bin/system/detect-os-mode 2>/dev/null

echo "OS_MODE Detceted: $OS_MODE"

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
            ./install/install-ubuntu
            break
            ;;
        "WSL2 Ubuntu")
            echo
            echo "Installing Dotfiles for $opt..."
            echo
            ./install/install-wsl2
            break
            ;;
        "Termux")
            echo
            echo "Installing Dotfiles for $opt..."
            echo
            ./install/install-termux
            break
            ;;
        *) echo "Invalid option $REPLY";;
    esac
done
