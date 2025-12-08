# Detect OS_MODE
source ~/bin/system/detect-os-mode 2>/dev/null

if [[ $- == *i* ]]; then
    echo "OS_MODE Detected: $OS_MODE"
fi

# Base PATH config
PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:~/.local/bin:/snap/bin/code:/snap/bin'

# Homebrew for macOS
if [ "$OS_MODE" = "MACOS" ]; then
   eval "$(/opt/homebrew/bin/brew shellenv)"
fi

PRETTY_PATH=$PATH

# Add ~/bin subfolders
for dir in "$HOME/bin"/*/; do
    dir=${dir%/}
    PATH=$PATH:"$dir"
    PRETTY_PATH=$PRETTY_PATH:"~${dir#$HOME}"
done

export PATH
export PRETTY_PATH

if [[ $- == *i* ]]; then
    echo "\$PATH=$PRETTY_PATH"
fi

# WSL2 config
if [ "$OS_MODE" = "WSL2" ]; then
    if [[ $- == *i* ]]; then
        echo "Sourcing: ~/.wsl2rc"
    fi
    source ~/.wsl2rc
fi

# Shortcuts
onedrive () { [ "$OS_MODE" = "WSL2" ] && cd "$OneDriveFolder" || echo "Not WSL2"; }
home () { [ "$OS_MODE" = "WSL2" ] && cd "$HomeFolder" || echo "Not WSL2"; }
c: () { [ "$OS_MODE" = "WSL2" ] && cd "/mnt/c" || echo "Not WSL2"; }
downloads () { [ "$OS_MODE" = "WSL2" ] && cd "$HomeFolder/Downloads" || echo "Not WSL2"; }
desktop () { [ "$OS_MODE" = "WSL2" ] && cd "$OneDriveFolder/Desktop" || echo "Not WSL2"; }

# Syntax highlighting via bat
bat () {
    if [ "$OS_MODE" == "WSL2" ]; then bat --paging=never --color=always "$@"
    elif [ "$OS_MODE" == "MACOS" ]; then $(which bat) --paging=never "$@"
    elif [ "$OS_MODE" == "TERMUX" ]; then bat --color=always "$@"
    else batcat --plain --paging=never --color=always "$@"; fi
}

# SSH Agent
if [[ $- == *i* ]]; then
    eval `ssh-agent`
fi

weather () { curl wttr.in/moon?QF; curl wttr.in/?n2QF; }

# Editors
VIM_PATH=$(which vim)
export EDITOR=$VIM_PATH
export VISUAL=$VIM_PATH
export SUDO_EDITOR=vim

# Aliases
alias sr='source ~/.bashrc'
alias br='vim ~/.bashrc'
alias lr='ls -atr --color=auto -C'
alias la='ls -axc --color=auto'
alias diff='diff --color=auto'

# FIXED ls aliases
alias ls='ls --color=auto'
alias l='ls -alFG'
alias ll='ls -CFG'

# Nautilus launcher
./() { (nohup nautilus "$1" >/dev/null 2>&1 & disown) >/dev/null 2>&1 ; }

# Back directories
-() { local n=${1:-1}; [[ $n =~ ^[0-9]+$ ]] || n=1; ((n<1)) && n=1; cd -P -- "$(printf '../%.0s' $(seq 1 "$n"))"; }

h() { cd; }
x() { exit; }

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

case $- in *i*) ;; *) return ;; esac

# History settings
HISTCONTROL=ignoreboth
export HISTIGNORE="ls:ll:cd:pwd:exit"
shopt -s histappend
if [ "$OS_MODE" = "MACOS" ]; then HISTSIZE=1000000; HISTFILESIZE=200000;
else HISTSIZE=-1; HISTFILESIZE=-1; fi

if [ "$OS_MODE" = "MACOS" ]; then
    export PROMPT_COMMAND='history -a; history -r'
else
    export PROMPT_COMMAND='history -a; history -c; history -r'
fi

hist () { history | sed 's/^[ ]*[0-9]*[ ]*//' | batcat --plain --color=always --language=bash --pager="less -R"; }

shopt -s checkwinsize
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Debian chroot
[ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ] && debian_chroot=$(cat /etc/debian_chroot)

force_color_prompt=yes
color_prompt=yes


unset color_prompt force_color_prompt

# Disable MacOS bash warning
export BASH_SILENCE_DEPRECATION_WARNING=1

# rbenv
command -v rbenv >/dev/null && eval "$(rbenv init -)"

# pnpm for MACOS
if [ "$OS_MODE" = "MACOS" ]; then
    cd "$OneDriveFolder"
    export PNPM_HOME="/Users/alistair.macdonald/Library/pnpm"
    case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
fi

export ANDROID_HOME=~/Library/Android/sdk/
alias adbrestart="adb kill-server && adb start-server"
alias adbrcon="adb reverse tcp:8081 tcp:8081"
alias myip='ifconfig en0 | grep inet'

toggle_vi() {
    if [[ $SHELLOPTS =~ vi ]]; then
        set -o emacs
        echo "Vi mode disabled"
    else
        set -o vi
        echo "Vi mode enabled"
    fi
}

# Antigravity
export PATH="/Users/user/.antigravity/antigravity/bin:$PATH"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

if [[ $- == *i* ]]; then

    # Plain-text git info: no colors here
    parse_git_branch() {
        git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

        local branch status x y
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --always 2>/dev/null) || return 0
        status=$(git status --porcelain 2>/dev/null)

        local has_staged=0 has_unstaged=0 has_untracked=0 has_conflicts=0
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            x=${line:0:1}
            y=${line:1:1}
            if   [[ "$x" == "U" || "$y" == "U" ]]; then has_conflicts=1
            elif [[ "$x" == "?" && "$y" == "?" ]]; then has_untracked=1
            else
                [[ "$x" != " " ]] && has_staged=1
                [[ "$y" != " " ]] && has_unstaged=1
            fi
        done <<< "$status"

        local ahead=0 behind=0
        if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
            read -r ahead behind < <(git rev-list --left-right --count HEAD...@{u})
        fi

        local symbol="⊢ $branch"
        local flags=""

        (( has_conflicts )) && flags+=" ✖"
        (( has_unstaged ))  && flags+=" ✚"
        (( has_staged   ))  && flags+=" ●"
        (( has_untracked )) && flags+=" …"

        if   (( ahead > 0 && behind > 0 )); then flags=" ⇅$flags"
        elif (( ahead > 0 ));               then flags=" ↑$flags"
        elif (( behind > 0 ));              then flags=" ↓$flags"
        fi

        printf '%s%s' "$symbol" "$flags"
    }

    # Path: parent blue, last segment (or ~) yellow – NO \[ \] here
    path_prompt() {
        local dir="$PWD" home="$HOME" parent base

        if [[ "$dir" == "$home" ]]; then
            printf '\033[01;33m~\033[0m'
        else
            parent=${dir%/*}
            base=${dir##*/}
            parent=${parent/#$home/\~}
            printf '\033[01;34m%s/\033[01;33m%s\033[0m' "$parent" "$base"
        fi
    }

    # Take plain git text and color it – NO \[ \] here
    git_prompt() {
        local info
        info=$(parse_git_branch)
        [[ -z "$info" ]] && return 0

        local green='\033[1;32m'
        local yellow='\033[1;33m'
        local red='\033[1;31m'
        local magenta='\033[1;35m'
        local color="$green"

        [[ "$info" == *✖* ]] && color="$magenta"                # conflicts
        [[ "$info" == *✚* || "$info" == *●* ]] && color="$yellow"  # changes
        [[ "$info" == *…* ]] && color="$red"                    # untracked

        printf '%b%s\033[0m' "$color" "$info"
    }

    # Final PS1: user@host PATH GIT \n $
    PS1="\[\033[01;32m\]\u\[\033[0m\]@\
\[\033[01;31m\]\h\[\033[0m\] \
\$(path_prompt) \
\$(git_prompt)\n\[\033[01;35m\]\$\[\033[0m\] "
fi
