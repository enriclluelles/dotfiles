function! plug_settings#load(...)
  call plug#begin('~/.config/nvim/plugged')

  " Using shorthand notation, all are github repos unless explicit url is used
  Plug 'junegunn/vim-easy-align'

  " On-demand loading
  Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
  Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

  " Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
  Plug 'fatih/vim-go', { 'tag': '*' }

  " Plugin options
  Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

  " Fuzzy finding utils
  Plug 'junegunn/fzf', { 'do': './install --bin' }
  Plug 'junegunn/fzf.vim'

  " Undo in tree mode
  Plug 'sjl/gundo.vim'

  " Git tools
  Plug 'tpope/vim-fugitive'
  " Helpers to operate with files
  Plug 'tpope/vim-eunuch'
  " Change word surroundings
  Plug 'tpope/vim-surround'
  " Add endings to common structures
  Plug 'tpope/vim-endwise'
  " Github theme
  Plug 'albertorestifo/github.vim'
  " Fancier but lean statusbar
  Plug 'vim-airline/vim-airline'

  " Initialize plugin system
  call plug#end()

  " Setup PlugLock and PlugRestore commands(as a la Gemfile.lock) to reference
  " git commits
  command! -nargs=0 -bar -bang PlugLock call s:lock()
  command! -nargs=0 -bar -bang PlugRestore call s:restore()
endfunction

let g:pluglock_config_path = "/.config/nvim/"
let g:pluglock_filename = $HOME . g:pluglock_config_path . "pluglock.vim"

function! s:lock()
  execute "PlugSnapshot " . g:pluglock_filename
endfunction

function! s:restore()
  execute "source ". g:pluglock_filename
endfunction
