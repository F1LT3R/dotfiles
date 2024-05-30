

## Patch MonoList with Nerdfont Glyphs

https://github.com/ryanoasis/nerd-fonts?tab=readme-ov-file#font-patcher

```
sudo apt install fontforge ttfautohint

git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts

FONT_PATH=/home/user/.local/share/fonts/MonoLisaCustom-Regular.ttf

fontforge -script font-patcher  ~/.local/share/fonts/MonoLisaCustom-Light.ttf --use-single-width-glyphs --complete -out ~/.local/share/fonts
fontforge -script font-patcher  ~/.local/share/fonts/MonoLisaCustom-Regular.ttf --use-single-width-glyphs --complete -out ~/.local/share/fonts
`
