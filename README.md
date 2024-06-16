# Dotfiles

## Install

### Symlink Dotfiles

⚠️ WARNING! This is a destructive action!

All scripts in `~/bin` will be forably moved to `~/bin/old`. Symlinks will overwrite files and directories when linking to this repository, Eg: `~/.bashrc` and `~/.vim/`.

```bash
# Clone this repo
mkdir -p ~/repos
git clone https://github.com/F1LT3R/dotfiles ~/repos/
```

```bash
# Run the installer menu
cd dotfiles
./install.sh
```

### Install NVM and Node.js

```bash
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
nvm install --lts
```

### Install Global Node Packages

```bash
npm i -g emoj
```

### Install Packages via CURL

#### YTDL

```bash
mkdir -p ~/.local/bin
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp
chmod a+rx ~/.local/bin/yt-dlp
```

## Keyboard Shortcuts

### VIM

Leader key is `,` (comma).

- `Ctrl + y` = Copy whole lines to clipboard w/ XClip.
- `Ctrl + q` = Fast quit.
- `, Space` = Clear search.
- `, 1` = Toggle number line.
- `Ctrl + f` = NERDTree toggle.
- `Ctrl + p` = Ripgrep files.
- `, p` = Ripgrep file contents.
- `Ctrl + \` = TComment toggle.
- `, t` = Thesaurus.
- `` , ` `` = Terminal split.
- `, \` = Terminal to Normal mode.
- `Ctrl + Cursor Keys` = Move focus between panes.
- `Shift + Cursor Keys` = Move position (order) of panes.
- `Ctrl + Shift + Cursor Keys` = Resize (expand / contract) panes.
- `Tab` = Next Buffer.
- `Shift + Tab` = Previous Buffer.
- `,,` = Writing mode (Goyo, Pencil).
- Chat-GPT Integration
    + `, x` = Complete line
    + `, f` = Role: `/fix_code`
    + `, r` = Role: `/rewrite` (low temp)
    + `, w` = Role: `/rewrite_creative` (high temp)
    + `, a` = Role: `/antonym`
    + `, s` = Role: `/synonym`
    + `, g` = Fix grammar and spelling
    + `, c` = Chat onsole

### Bash Aliases

- `br` = Edit `~/.bashrc` in VIM.
- `sr` = Source `~/.bashrc`.
- `lr` = Horizontal `ls`, latest changed last (for mobile).
- `la` = Horizontal `ls`, showing hidden files (for mobile).
- `u` = Move up a directory.
- `h` = Goto user home directory.
- `cat` = Batcat syntax highlighting, plain mode.
- `x` = Quick exit for terminal session.
- `weather` = Show moon phase, and two-day weather.

### Bin Commands

- Git
    + `gl $1` = Git Log Pretty for search term. Pipes to Less in Pager mode.
- Shell
    + `clean` = Recursively remove `node_modules` and `.git`
        dirs.
    + `s` = Run `npm start`.
    + `v` = Run `vim $@`.
    + `t` = Run `tree $@`.
    + `tg` = Grep for `$1` with `tree`.
    + `vc` = Open `.vimrc` in VIM.
- WSL2
    + `e` = Open `explorer.exe` in current directory.
    + `hosts` = Open Windows hosts file.
    + `pom` = Start Pomodoro timer.
    + `w` = Open web browser at `$1`.
- Opsec
    + `fingerprints` = List `~/.ssh/*.pub` keys in hexadecimal (Azure).
    + `fingerprints-sha` = List `~/.ssh/*.pub` keys in SHA256 (GitHub).
    + `key` = Generate secure key from `$1`, with `$2` length.
    + `pass` = Generate secure pass from `$1` (domain), and `$2` (username/email), with `$3` length.
    + `ssh-gen` = Generate `ed25519` key pair with `$1` (email)

### Patch a Font with Nerdfont Glyphs

https://github.com/ryanoasis/nerd-fonts?tab=readme-ov-file#font-patcher

```bash
sudo apt install fontforge ttfautohint

git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts

FONT_PATH=/home/user/.local/share/fonts/MonoLisaCustom-Regular.ttf

fontforge -script font-patcher  ~/.local/share/fonts/MonoLisaCustom-Light.ttf --use-single-width-glyphs --complete -out ~/.local/share/fonts
fontforge -script font-patcher  ~/.local/share/fonts/MonoLisaCustom-Regular.ttf --use-single-width-glyphs --complete -out ~/.local/share/fonts
```
