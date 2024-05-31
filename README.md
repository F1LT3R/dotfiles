# Dotfiles

## VIM

Leader key is `,` (comma).

- `Ctrl + q` - Fast quit.
- `, Space` - Clear search.
- `, 1` - Toggle number line.
- `Ctrl + f` - NERDTree toggle.
- `Ctrl + p` - Ripgrep files.
- `, p` - Ripgrep file contents.
- `Ctrl + \` - TComment toggle.
- `, T` - Thesaurus.
- `` , ` `` - Terminal split.
- `, \` - Terminal to Normal mode.
- `Ctrl + Cursor Keys` - Move focus between panes.
- `Shift + Cursor Keys` - Move position (order) of panes.
- `Ctrl + Shift + Cursor Keys` - Resize (expand / contract) panes.
- `Tab` - Next Buffer
- `Shift + Tab` - Previous Buffer
nnoremap <S-Tab> :bprevious<CR>
- Chat-GPT Integration
    + `, x` - Complete line
    + `, f` - Role: `/fix_code`
    + `, r` - Role: `/rewrite` (low temp)
    + `, w` - Role: `/rewrite_creative` (high temp)
    + `, a` - Role: `/antonym`
    + `, s` - Role: `/synonym`
    + `, g` - Fix grammar and spelling
    + `, c` - Chat onsole

## Bash Aliases

- `b` = Edit `~/.bashrc` in VIM.
- `s` = Source `~/.bashrc`.
- `lr` = Horizontal `ls`, latest changed last (for mobile).
- `la` = Horizontal `ls`, showing hidden files (for mobile).
- `u` = Move up a directory.
- `h` = Goto user home directory.
- `cat` = Batcat syntax highlighting, plain mode.
- `x` = Quick exit for terminal session.

## Bin Commands

- Shell
    + `clean` - Recursively remove `node_modules` and `.git`
        dirs.
    + `s` - Run `npm start`.
    + `v` - Run `vim $@`.
    + `t` - Run `tree $@`.
    + `tg` - Grep for `$1` with `tree`.
    + `vc` - Open `.vimrc` in VIM.
- WSL2
    + `e` - Open `explorer.exe` in current directory.
    + `hosts` - Open Windows hosts file.
    + `pom` - Start Pomodoro timer.
    + `w` - Open web browser at `$1`.
- Opsec
    + `fingerprints` - List `~/.ssh/*.pub` keys in
      hexadecimal (Azure).
    + `fingerprints-sha` - List `~/.ssh/*.pub` keys in
        SHA256 (GitHub).
    + `key` - Generate secure key from `$1`, with `$2`
        length.
    + `pass` - Generate secure pass from `$1` (domain), and
        `$2` (username/email), with `$3` length.
    + `ssh-gen` - Generate `ed25519` key pair with `$1` (email)

## Patch a Font with Nerdfont Glyphs

https://github.com/ryanoasis/nerd-fonts?tab=readme-ov-file#font-patcher

```bash
sudo apt install fontforge ttfautohint

git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts

FONT_PATH=/home/user/.local/share/fonts/MonoLisaCustom-Regular.ttf

fontforge -script font-patcher  ~/.local/share/fonts/MonoLisaCustom-Light.ttf --use-single-width-glyphs --complete -out ~/.local/share/fonts
fontforge -script font-patcher  ~/.local/share/fonts/MonoLisaCustom-Regular.ttf --use-single-width-glyphs --complete -out ~/.local/share/fonts
```
