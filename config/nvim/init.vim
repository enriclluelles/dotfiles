" PLUG
" Each plugin settings are defined after the Plug
call plug#begin('~/.config/nvim/plugged')

  " {{{{{{{{{{  COC
  Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}

  " Make coc-ruby play nice with chruby
  let ruby = "2.4.1"
  if $RUBY_VERSION != ""
    let ruby = $RUBY_VERSION
  end
  let g:ruby_host_prog = '~/.gem/ruby/' . ruby . '/bin/neovim-ruby-host'
  " Autoinstall extensions
  let g:coc_global_extensions = ['coc-solargraph', 'coc-flow', 'coc-tsserver', 'coc-eslint', 'coc-json']

  " Use tab for trigger completion with characters ahead and navigate.
  " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
  inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : <SID>check_back_space() ? "\<TAB>" : coc#refresh()
  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  " Use <c-space> for trigger completion.
  inoremap <silent><expr> <c-space> coc#refresh()

  " Use <cr> for confirm completion.
  " Coc only does snippet and additional edit on confirm.
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : ""

  nmap <silent>gd <Plug>(coc-definition)
  nmap <silent>gy <Plug>(coc-type-definition)
  nmap <silent>gi <Plug>(coc-implementation)
  nmap <silent>gr <Plug>(coc-references)
  nmap <leader>rn <Plug>(coc-rename)
  " }}}}}}}}}} COC

  " {{{{{{{{{{ Language support
  Plug 'pangloss/vim-javascript'
  Plug 'MaxMEllon/vim-jsx-pretty'
  " }}}}}}}}}} Language support

  Plug 'editorconfig/editorconfig-vim'

  Plug 'junegunn/vim-easy-align'
  " Start interactive EasyAlign in visual mode (e.g. vipga)
  xmap ga <Plug>(EasyAlign)

  " Start interactive EasyAlign for a motion/text object (e.g. gaip)
  nmap ga <Plug>(EasyAlign)

  " On-demand loading
  Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
  Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

  " Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
  Plug 'fatih/vim-go', { 'tag': '*' }

  Plug 'nsf/gocode'

  " {{{{{{{{{{ FZF
  Plug 'junegunn/fzf', { 'do': './install --bin' }
  Plug 'junegunn/fzf.vim'

  let g:fzf_command_prefix = 'FZF'
  let $FZF_DEFAULT_COMMAND = 'rg --files'
  nnoremap <leader><leader>f :FZFFiles<cr>
  nnoremap <leader><leader>b :FZFBuffers<cr>
  nnoremap <leader><leader>g :FZFRg<space>
  nnoremap <leader><leader>v :FZFRg<c-r><c-w><cr>
  " }}}}}}}}}} FZF

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
  " Test files
  Plug 'janko/vim-test'
call plug#end()

" Set up :PlugLock and :PlugRestore
command! -nargs=0 -bar -bang PlugLock call s:lock()
command! -nargs=0 -bar -bang PlugRestore call s:restore()

let g:pluglock_config_path = "/.config/nvim/"
let g:pluglock_filename = $HOME . g:pluglock_config_path . "pluglock.vim"

function! s:lock()
  execute "PlugSnapshot " . g:pluglock_filename
endfunction

function! s:restore()
  execute "source ". g:pluglock_filename
endfunction
" END PLUG

set nocompatible
syntax enable
set encoding=utf-8

filetype plugin indent on

"a

set background=light

set relativenumber
set ruler       " show the cursor position all the time
" set cursorline
set showcmd     " display incomplete commands

" Allow backgrounding buffers without writing them, and remember marks/undo
" for backgrounded buffers
set hidden

"" Whitespace
set nowrap                        " don't wrap lines
set tabstop=2                     " a tab is two spaces
set shiftwidth=2                  " an autoindent (with <<) is two spaces
set expandtab                     " use spaces, not tabs
set list                          " Show invisible characters
set backspace=indent,eol,start    " backspace through everything in insert mode
" List chars
set listchars=""                  " Reset the listchars
set listchars=tab:\ \             " a tab should display as "  ", trailing whitespace as "."
set listchars+=trail:.            " show trailing spaces as dots
set listchars+=extends:>          " The character to show in the last column when wrap is
                                  " off and the line continues beyond the right of the screen
set listchars+=precedes:<         " The character to show in the first column when wrap is
                                  " off and the line continues beyond the left of the screen
"" Searching
set hlsearch                      " highlight matches
set incsearch                     " incremental searching
set ignorecase                    " searches are case insensitive...
set smartcase                     " ... unless they contain at least one capital letter

function s:setupWrapping()
  set wrap
  set wrapmargin=2
endfunction

if has("autocmd")
  " In Makefiles, use real tabs, not tabs expanded to spaces
  au FileType make set noexpandtab

  " Make sure all markdown files have the correct filetype set and setup wrapping
  au BufRead,BufNewFile *.{md,markdown,mdown,mkd,mkdn,txt} setf markdown | call s:setupWrapping()

  " Treat JSON files like JavaScript
  au BufNewFile,BufRead *.json set ft=javascript

  " make Python follow PEP8 ( http://www.python.org/dev/peps/pep-0008/ )
  au FileType python set softtabstop=4 tabstop=4 shiftwidth=4 textwidth=79
  au FileType objc set softtabstop=4 tabstop=4 shiftwidth=4
  au FileType objcpp set softtabstop=4 tabstop=4 shiftwidth=4

  au FileType go set noexpandtab

  " Remember last location in file, but not for commit messages.
  " see :help last-position-jump
  au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g`\"" | endif
endif

" provide some context when editing
set scrolloff=3

" don't use Ex mode, use Q for formatting
map Q gq

" clear the search buffer when hitting return
" :nnoremap <CR> :nohlsearch<cr>

" http://vimcasts.org/e/14
cnoremap %% <C-R>=expand('%:h').'/'<cr>
cnoremap %p <C-R>=expand('%:.')<cr>

" ignore Rubinius, Sass cache files
set wildignore+=*.rbc,*.scssc,*.sassc
" ignore assets and shit for rails apps
set wildignore+=public/system,public/assets,public/uploads
set wildignore+=*.png,*.jpg
" ignore tmp dir and .git dir
set wildignore+=.git,tmp,tags
set wildignore+=*.class,*.jar
" ignore c and c++ objects
set wildignore+=*.o

" folding options
set foldmethod=indent
set foldlevel=10

" use system clipboard
set clipboard=unnamedplus

let g:jsx_ext_required = 0

let g:go_fmt_command = "goimports"

" activate rainbow parentheses
let g:rbpt_loadcmd_toggle = 1

nnoremap <Leader>t :Files<CR>


"snipmate
let g:snipMate = {}
let g:snipMate.scope_aliases = {} 
let g:snipMate.scope_aliases['jst'] = 'html'

"disable jshint highlighting
let g:JSHintHighlightErrorLine = 0

" supertab
let g:SuperTabCompletionContexts = ['s:ContextText', 's:ContextDiscover']
let g:SuperTabContextTextOmniPrecedence = ['&omnifunc', '&completefunc']
let g:SuperTabContextDiscoverDiscovery =
      \ ["&completefunc:<c-x><c-u>", "&omnifunc:<c-x><c-o>"]

"use ag instead of ack
let g:ackprg = 'ag --nogroup --nocolor --column'

"tabular
nmap <Leader>a= :Tabularize /=<CR>
vmap <Leader>a= :Tabularize /=<CR>
nmap <Leader>a: :Tabularize /:\zs<CR>
vmap <Leader>a: :Tabularize /:\zs<CR>
nmap <Leader>as :%s/\s/  /\| Tabularize multiple_spaces<CR>\| :nohl<CR>
nmap <Leader>a<Space> :Tabularize multiple_spaces<CR>
vmap <Leader>a<Space> :Tabularize multiple_spaces<CR>

"use commentary mappings
xmap \\  <Plug>Commentary
nmap \\  <Plug>Commentary
nmap \\\ <Plug>CommentaryLine
nmap \\u <Plug>CommentaryUndo

" map NERDTreeToogle
map <Leader>n :NERDTreeToggle<CR>

nnoremap <leader><leader> <c-^>

" find merge conflict markers
nmap <silent> <leader>cf <ESC>/\v^[<=>]{7}( .*\|$)<CR>

command! KillWhitespace :normal :%s/ *$//g<cr><c-o><cr>

" easier navigation between split windows
" nnoremap <c-j> <c-w>j
" nnoremap <c-k> <c-w>k
" nnoremap <c-h> <c-w>h
" nnoremap <c-l> <c-w>l

" map the . in visual mode to execute the . command over a range
vnoremap . :norm .<cr>

" disable cursor keys in normal mode
map <Left>  :echo "no!"<cr>
map <Right> :echo "no!"<cr>
map <Up>    :echo "no!"<cr>
map <Down>  :echo "no!"<cr>

set backupdir=~/.vim/_backup    " where to put backup files.
"set directory=~/.vim/_temp      " where to put swap files.
set noswapfile
set undodir=~/.vim/_undo        " undo
set undofile

set laststatus=2
