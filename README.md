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
- `-` = Move up a directory.
- `h` = Goto user home directory.
- `cat` = Batcat syntax highlighting, plain mode.
- `x` = Quick exit for terminal session.
- `weather` = Show moon phase, and two-day weather.
- `./` = Open current DIR in Nautilus.

### Bin Commands

- Git
    + `gl $1` = Git Log Pretty for search term. Pipes to Less in Pager mode.
    + `gla $1` = Git Log --all. Graphed Pretty for search term. $1 = Search term. $1 is optional.
    + `gs` = Git Status. Piped to Less pager.
    + `gb $1 $2 $3` = Git Blame. $1 = File. $2 Line. $3 End Line. $2 and $3 are optional.
    + `gd $1 $1` = Git Diff. $1 = Git Ref (branch, hash, HEAD^, etc). Piped to Less pager. $1 and $1 are optional.
    + `gdn $1 $1` = Git Diff --name-only. $1 = Git Ref (branch, hash, HEAD^, etc). Piped to Less pager. $1 and $1 are optional.
    + `gc` = Git Conflicting Files. Runs from root of repo.
    + `gc.` = Git Conflicting Files. Runs from present directory.
- Shell
    + `clean` = Recursively remove `node_modules` and `.git`
        dirs.
    + `s` = Run `npm start`.
    + `v` = Run `vim $@`.
    + `t` = Run `tree $@`.
    + `f` = Find resursive `find $1 $2` where $1 is PATH and $2 is filename.
    + `tg` = Grep for `$1` with `tree`.
    + `vc` = Open `.vimrc` in VIM.
    + `rl` = Read line from file where $1 is the filepath and $2 is the line to read.
    + `cl` = Copy line from file to clipboard where $1 is the filepath and $2 is the line to read. Uses `xsel`.
    + `ht` = Start `http-server` with Caching disabled. Install globally with `npm i -g http-server`.
    + `k9` = Kill all processes like `$1`, eg: `k9 "http-server"`.
- WSL2
    + `e` = Open `explorer.exe` in current directory.
    + `c:` = Change directory to `/mnt/c`.
    + `home` = Change directory to Windows `$HomeFolder`.
    + `onedrive` = Change directory to Microsoft OneDrive folder.
    + `desktop` = Change directory to `$OneDrive`/Desktop folder. 
    + `downloads` = Change directory to `$HomeFolder`/Downloads. 
    + `hosts` = Open Windows hosts file.
    + `pom` = Start Pomodoro timer.
    + `w` = Open web browser at `$1`.
    + `vsproj-backup` = Copy Visual Studio Project to new dir, where `$1` is SOURCE_DIR and `$2` is DEST_DIR, excluding dirs: bin, obj, .vs, packages, node_modules.
- Opsec
    + `fingerprints` = List `~/.ssh/*.pub` keys in hexadecimal (Azure).
    + `fingerprints-sha` = List `~/.ssh/*.pub` keys in SHA256 (GitHub).
    + `key` = Generate secure key from `$1`, with `$2` length.
    + `pass` = Generate secure pass from `$1` (domain), and `$2` (username/email), with `$3` length.
    + `ssh-gen` = Generate `ed25519` key pair with `$1` (email).
- Media
	+ `fix-clarett` = Fix Clarett soundboard after swapping USB ports. 

### Silent

Silent tagging system.

- `!! acheived` = win, celebrate, improvement, accomplishment
- `#hashtag` = tag, hashtag
- `$$variable` = variable, variable=value, $variable (to use)
- `~ todo` = todo, task, todo-spec-compatibility
- `^ improve` = to-improve, or refine, personal or project
- `%datetime` = date or time
- `@name` = person, group, company, entity
- `&&link` = link, link:[linemchar]
- `"" reminder` = reminder, popup
- `::include` = include, include:[line-start,line-end]
- `*project` = project, category

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

### Fix Clarrett Soundboard on Ubuntu

```bash
pactl list cards
pactl set-card-profile alsa_card.usb-Focusrite_Clarett__8Pre_00004316-00 output:multichannel-output+input:multichannel-input
```