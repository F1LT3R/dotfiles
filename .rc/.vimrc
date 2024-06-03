let g:ale_disable_lsp = 1
filetype plugin indent on
" set termguicolors

set noerrorbells
set noswapfile
set noundofile

set number
set nowrap

set tabstop=4
set shiftwidth=4
" set expandtab

<<<<<<< Updated upstream
let g:markdown_fenced_languages = ['html', 'javascript', 'bash']
=======

let g:markdown_fenced_languages = ['html', 'javascript', 'shell']
>>>>>>> Stashed changes

" Copy whole lines to clipboard using XClip
" Update to XSEL later
vnoremap <C-y> :w !xclip -selection clipboard<CR><CR>

" Setup following on Termux later:
" https://ibnishak.github.io/blog/post/copy-to-termux-clip/

" Fast quit
nnoremap <C-q> :qa!<CR>

" Set Leader to Comma
let mapleader=","


" Needs VIM compiled with Python 2.4+
"nnoremap <A-n> :GundoToggle<CR>

" Fix VIMs Regex Formatting for searches
nnoremap / /\v
vnoremap / /\v

" Case Insensitive Seach
set ignorecase
set smartcase

" Substitute globally by default
set gdefault

" Show results as typing
set incsearch
set showmatch
set hlsearch

" Clear the Search
nnoremap <leader><space> :noh<cr>

" Change Cursor Shape for Different Modes
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" Chat-GPT Integration
let g:vim_ai_token_file_path = '~/.secrets/openai.token'
let g:vim_ai_roles_config_file = '~/.config/vim-ai/chat-gpt-roles.ini'

let g:vim_ai_complete = {
\  "engine": "complete",
\  "options": {
\    "model": "gpt-3.5-turbo-instruct",
\    "endpoint_url": "https://api.openai.com/v1/completions",
\    "max_tokens": 1000,
\    "temperature": 0.5,
\    "request_timeout": 20,
\    "enable_auth": 1,
\    "selection_boundary": "#####",
\  },
\  "ui": {
\    "paste_mode": 1,
\  },
\}

let g:vim_ai_edit = {
\  "engine": "complete",
\  "options": {
\    "model": "gpt-4o",
\    "endpoint_url": "https://api.openai.com/v1/completions",
\    "max_tokens": 1000,
\    "temperature": 0.1,
\    "request_timeout": 20,
\    "enable_auth": 1,
\    "selection_boundary": "#####",
\  },
\  "ui": {
\    "paste_mode": 1,
\  },
\}

let g:vim_ai_chat = {
\  "options": {
\    "model": "gpt-4o",
\    "endpoint_url": "https://api.openai.com/v1/chat/completions",
\    "max_tokens": 1000,
\    "temperature": 1,
\    "request_timeout": 20,
\    "enable_auth": 1,
\    "selection_boundary": "",
\  },
\  "ui": {
\    "code_syntax_enabled": 1,
\    "populate_options": 0,
\    "open_chat_command": "preset_below",
\    "scratch_buffer_keep_open": 0,
\    "paste_mode": 1,
\  },
\}

" complete text on the current line or in visual selection
nnoremap <leader>f :AI /fix_code<CR>
xnoremap <leader>f :AI /fix_code<CR>

nnoremap <leader>x :AI<CR>
xnoremap <leader>x :AI<CR>

xnoremap <leader>r :AI /rewrite<CR>
xnoremap <leader>r :AI /rewrite<CR>

nnoremap <leader>w :AI /rewrite_creative<CR>
nnoremap <leader>w :AI /rewrite_creative<CR>

xnoremap <leader>a :AI /antonym<CR>
nnoremap <leader>a :AI /antonym<CR>

xnoremap <leader>s :AI /synonym<CR>
nnoremap <leader>s :AI /synonym<CR>

xnoremap <leader>g :AIEdit fix grammar and spelling<CR>
nnoremap <leader>g :AIEdit fix grammar and spelling<CR>

" trigger chat
xnoremap <leader>c :AIChat<CR>
nnoremap <leader>c :AIChat<CR>

" redo last AI command
nnoremap <leader>r :AIRedo<CR>

syntax on

" Toggle line numbers
nnoremap <leader>1 :set number!<CR>

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['eslint'],
\}
let g:ale_fix_on_save = 1

" GOLANG SETUP GUIDE: https://pmihaylov.com/vim-for-go-development/
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1

" disable all linters as that is taken care of by coc.nvim
let g:go_diagnostics_enabled = 0
let g:go_metalinter_enabled = []
"
" don't jump to errors after metalinter is invoked
let g:go_jump_to_error = 0

" run go imports on file save
let g:go_fmt_command = "goimports"

" automatically highlight variable your cursor is on
let g:go_auto_sameids = 0

let g:ale_sign_error = '❌'
let g:ale_sign_warning = '⚠️'

set signcolumn=number

" FZF SETTINGS: https://dev.to/iggredible/how-to-search-faster-in-vim-with-fzf-vim-36ko
" INSTALL FZF
" git clone https://github.com/junegunn/fzf.git ~/.vim/pack/packages/start/fzf
" git clone https://github.com/junegunn/fzf.vim.git ~/.vim/pack/packages/start/fzf.vim
nnoremap <silent> <C-p> :Files<CR>
nnoremap <silent> <Leader>p :Rg<CR>

" NERDTree
nnoremap <C-f> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1

" let g:syntastic_go_checkers = "gofmt"
" let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }

let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

filetype plugin on
map <C-\> :TComment<CR>
set laststatus=2

function! s:thesaurus()
    set completeopt=menu,menuone,noinsert,noselect
    let s:saved_ut = &ut
    if &ut > 200 | let &ut = 200 | endif
    augroup ThesaurusAuGroup
        autocmd CursorHold,CursorHoldI <buffer>
                    \ let &ut = s:saved_ut |
                    \ set iskeyword-=32 |
                    \ autocmd! ThesaurusAuGroup
    augroup END
    return ":set iskeyword+=32\<cr>vaWovea\<c-x>\<c-t>"
endfunction

nnoremap <expr> <leader>t <SID>thesaurus()

set thesaurus+=~/.vim/thesaurus/thesaurii.txt

function! MyHighlights() abort
    hi clear SpellBad
    hi clear SpellCap
    hi clear SpellRare
    hi clear SpellLocal
    highlight SpellBad cterm=NONE gui=NONE guibg=#ff0000 guifg=#ffffff
    highlight SpellCap cterm=NONE gui=NONE guibg=#aa0000 guifg=#eeeeee
    highlight SpellRare cterm=NONE gui=NONE guibg=#cc00cc guifg=#ffffff
    highlight SpellLocal cterm=NONE gui=NONE guibg=#0000cc guifg=#ffffff
endfunction

augroup MyColors
    autocmd!
    autocmd ColorScheme * call MyHighlights()
augroup END

set spellfile=~/.config/dotfiles/lib/spell/dict_words_en_us.add

" Map <leader>t to open a terminal
set splitbelow
" set termwinsize=10x0
nnoremap <leader>` :terminal<CR>

" Map Ctrl + Backslash to switch terminal to normal mode
tnoremap <C-\> <C-\><C-n>

" Ctrl + Arrow Between Panes
nnoremap <C-Left> <C-w>h
nnoremap <C-Down> <C-w>j
nnoremap <C-Up> <C-w>k
nnoremap <C-Right> <C-w>l

" Move Panes
nnoremap <A-Left> <C-w>H
nnoremap <A-Right> <C-w>L
nnoremap <A-Up> <C-w>K
nnoremap <A-Down> <C-w>J

" Resize Panes
nnoremap <silent> <S-Left> :vertical resize -4<CR>
nnoremap <silent> <S-Right> :vertical resize +4<CR>
nnoremap <silent> <S-Up> :resize +4<CR>
nnoremap <silent> <S-Down> :resize -4<CR>

:hi SpecialKey ctermfg=8
:set listchars=eol:¬,tab:⠐⠐⠕,trail:~,extends:>,precedes:<,space:⠐
:hi NonText ctermfg=8
nnoremap <silent> <C-l> :set list!<CR>

nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>

" Automatically enable Pencil in Goyo mode
autocmd User GoyoEnter call pencil#init()
autocmd User GoyoEnter Limelight
autocmd User GoyoEnter set nolist
autocmd User GoyoLeave Limelight!
autocmd User GoyoLeave set list

" Customize Pencil settings
let g:pencil#wrapModeDefault = 'soft'
let g:pencil#autoformat = 1

" Toggle Goyo with a key mapping
nnoremap <Leader>, :Goyo<CR>

" Remap Ctrl + Z to prevent it from suspending Vim
nnoremap <C-z> <Nop>
vnoremap <C-z> <Nop>
inoremap <C-z> <Nop>
cnoremap <C-z> <Nop>

" colorscheme xcodedarkvhc
colorscheme radicalgoodspeed
" hi Normal guibg=#000000 guifg=#DDDDDD
" set cursorline
" hi CursorLine guibg=Grey10
