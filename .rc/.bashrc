# Detect OS_MODE
echo "Current Directory at Start: $(pwd)"

source ~/bin/system/detect-os-mode 2>/dev/null
echo "OS_MODE Detected: $OS_MODE"

# Pull in WSL2 Variables
# .wsl2rc lives outside of the dotfiles repo
if [ "$OS_MODE" = "WSL2" ]; then
    echo "Sourcing: ~/.wsl2rc"
    source ~/.wsl2rc
fi

# Windows Shortcuts
onedrive () {
    if [ "$OS_MODE" = "WSL2" ]; then
        cd "$OneDriveFolder"
    else
        echo "This is not WSL2."
    fi
}

home () {
    if [ "$OS_MODE" = "WSL2" ]; then
        cd "$HomeFolder"
    else
        echo "This is not WSL2."
    fi
}

c: () {
    if [ "$OS_MODE" = "WSL2" ]; then
        cd "/mnt/c"
    else
        echo "This is not WSL2."
    fi
}

downloads () {
    if [ "$OS_MODE" = "WSL2" ]; then
        cd "$HomeFolder/Downloads"
    else
        echo "This is not WSL2."
    fi
}

desktop () {
    if [ "$OS_MODE" = "WSL2" ]; then
        cd "$OneDriveFolder/Desktop"
    else
        echo "This is not WSL2."
    fi
}


# Terminal Syntax Highlighting
cat () {
    if [ "$OS_MODE" == "WSL2" ]; then
        bat --plain --color=always "$@"
    elif [ "$OS_MODE" == "TERMUX" ]; then
        bat --plain --color=always "$@"
    else
        batcat --plain --color=always "$@"
    fi
}

# Load SSH-Agent
eval `ssh-agent`

# Add ~/.local/bin to PATH
PRETTY_PATH=''

for dir in "$HOME/bin"/*/; do
    dir=${dir%/}  # Remove trailing slash
    PATH=$PATH:"$dir"
    PRETTY_PATH=$PRETTY_PATH:"~${dir#$HOME}"
done

echo "Bin Paths Added: $PRETTY_PATH"
export PATH

weather () {
    curl wttr.in/moon?QF
    curl wttr.in/?n2QF
}

# Set VIM as default editor
VIM_PATH=$(which vim)
export EDITOR=$VIM_PATH
export VISUAL=$VIM_PATH
export SUDO_EDITOR=vim
# sudo update-alternatives --config editor

# Quick source
alias sr='source ~/.bashrc'
alias br='vim ~/.bashrc'

# Mobile ls
alias lr='ls -atr --color=auto -C'
alias la='ls -ax'

# Up Dir (Only works at end of rc file)
u() {
    cd ..
}

# Home
h() {
    cd
}

# Quick EXit
x() {
    exit
}

# Node.js & NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# Ignore useless commands
export HISTIGNORE="ls:ll:cd:pwd:exit"

# Append to the history file, don't overwrite it
shopt -s histappend

# Infinite History Length
HISTSIZE=-1
HISTFILESIZE=-1

# Use Timestamps w/ History
# export HISTTIMEFORMAT="%F %T "

# Ensure the history is updated after each command
export PROMPT_COMMAND='history -a; history -c; history -r'

# History with syntax highlight
hist () {
    if [ "$OS_MODE" = "WSL2" ]; then
        history | sed 's/^[ ]*[0-9]*[ ]*//' | bat --plain --color=always --language=bash --pager="less -R"
    else
        history | sed 's/^[ ]*[0-9]*[ ]*//' | batcat --plain --color=always --language=bash --pager="less -R"
    fi
}

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

force_color_prompt=yes
color_prompt=yes

parse_git_branch() {
    # git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/  \1/'
    # git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ 🌿⤛ \1/'
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ ⤛ \1/'
}

if [ "$color_prompt" = yes ]; then
    # ⮞✨⚡🔥👘💎💻🕯 💡📁⛏ ➡✝☦🕎▶⚕🔰✳✴❇🏁🗡❇⚔ ▶
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;34m\]\w\[\033[01;31m\]$(parse_git_branch)\[\033[00m\] ▶ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)\$ '
fi

unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# # Alias definitions.
# # You may want to put all your additions into a separate file like
# # ~/.bash_aliases, instead of adding them here directly.
# # See /usr/share/doc/bash-doc/examples in the bash-doc package.
# if [ -f ~/.bash_aliases ]; then
#     . ~/.bash_aliases
# fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
