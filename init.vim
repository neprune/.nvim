" Base Configuration
" ===================

"   Set <leader> to ','.
    let mapleader = ","

"   'jj' to escape.
    imap jj <Esc>

"   Spaces, not tabs.
    set expandtab
    set tabstop=4
    set softtabstop=4
    set shiftwidth=4

"   Show me whitespace stuff.
    set list

"   Show line numbers...
    set number
"   apart from for terminals.
    autocmd TermOpen * setlocal nonumber norelativenumber


"   Open new vertical splits to the right.
    set splitright

"   Open new horizontal splits below.
    set splitbelow

"   ',q' to close current split.
    nnoremap <leader>q :q<CR>
"   ',v' to open a new vsplit.
    nnoremap <leader>v :vsplit:ene<CR>
"   ',s' to open a new split.
    nnoremap <leader>s :split<CR>:ene<CR>
"   ',t' to open a new tab.
    nnoremap <leader>t :tab<CR>:ene<CR>

"   Navigate windows with WASD ',m<direction>'.
    map <leader>mw <C-w><Up>
    map <leader>ma <C-w>h
    map <leader>ms <C-w><Down>
    map <leader>md <C-w>l


"   ',t<number>' to go to numbered tab.
    nnoremap <leader>t1 1gt
    nnoremap <leader>t2 2gt
    nnoremap <leader>t3 3gt
    nnoremap <leader>t4 4gt
    nnoremap <leader>t5 5gt
    nnoremap <leader>t6 6gt
    nnoremap <leader>t7 7gt
    nnoremap <leader>t8 8gt
    nnoremap <leader>t9 9gt
    nnoremap <leader>t0 :tablast<CR>

"   ',cv' to open the vimrc in a in vertical split.
    map <leader>cv :vsp $MYVIMRC<CR>
"   ',cs' to open the vimrc in a in horizontal split.
    map <leader>cs :sp $MYVIMRC<CR>
"   ',ct' to open the vimrc in a in a new tab.
    map <leader>ct :tabnew $MYVIMRC<CR>
"   ',c.' to open the vimrc in the current buffer.
    map <leader>c. :e $MYVIMRC<CR>
"   ',cr' to reload the vimrc.
    map <leader>cr :source $MYVIMRC<CR>

"   Use 'tab' to cycle through auto-complete suggestions.
    inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
    inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

"    Navigate errors.
     map <C-n> :cnext<CR>
     map <C-m> :cprevious<CR>
     nnoremap <leader>a :cclose<CR>

"    Copy to system clipboard.
     map yc "*y

"    No swapfiles - I tend to save regularly and don't appreciate the faff.
     set noswapfile

" Plugins (using vim-plug)
" ========================
"   :PlugUpdate to install or update plugins.
"   :PlugUpgrade upgrade vim-plug itself.

    call plug#begin('~/.config/nvim/plugged')

"     Aesthetics
"     ==========
"         Solarized.
          Plug 'overcache/NeoSolarized'

"         Status line.
          Plug 'vim-airline/vim-airline'

"         Themes for the status line.
          Plug 'vim-airline/vim-airline-themes'

"              Set up solarized.
               let g:airline_theme='solarized'
               let g:airline_solarized_bg='dark'

"         JSON syntax highlighting.
          Plug 'elzr/vim-json'

"         Fish syntax.
          Plug 'khaveesh/vim-fish-syntax'

"         Colours for the tab line.
          function! g:BuffetSetCustomColors()
              hi! BuffetCurrentBuffer cterm=NONE ctermbg=5 ctermfg=8 guibg=#FFFFFF guifg=#000000
          endfunction


"     Functionality
"     =============
"         Better terminal navigation UX than nvim default.
          Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}

"              ',TR' to open terminal in float.
               nmap <leader>TR <cmd>ToggleTerm<cr>

"              ',TT' to open terminal in tab.
               nmap <leader>TT <cmd>ToggleTerm direction=tab<cr>

"              ',TG' to open terminal in vertical.
               nmap <leader>TG <cmd>ToggleTerm direction=vertical<cr>

"              ',T' to toggle open / close the terminal (not exit).

"         Organise things into projects.
          Plug 'ahmedkhalf/project.nvim'


"         Language aware line splitting and joining.
          Plug 'AndrewRadev/splitjoin.vim'

"             'gS' to split a line.
"             'gJ' to join multiple lines.

"         IDE like tabs.
          Plug 'bagrat/vim-buffet'

"              Show numbers.
               let g:buffet_show_index=1

"              Switch between buffers.
               nmap <leader>1 <Plug>BuffetSwitch(1)
               nmap <leader>2 <Plug>BuffetSwitch(2)
               nmap <leader>3 <Plug>BuffetSwitch(3)
               nmap <leader>4 <Plug>BuffetSwitch(4)
               nmap <leader>5 <Plug>BuffetSwitch(5)
               nmap <leader>6 <Plug>BuffetSwitch(6)
               nmap <leader>7 <Plug>BuffetSwitch(7)
               nmap <leader>8 <Plug>BuffetSwitch(8)
               nmap <leader>9 <Plug>BuffetSwitch(9)
               nmap <leader>0 <Plug>BuffetSwitch(10)

"         Fuzzy finder.
          Plug 'nvim-lua/plenary.nvim'
          Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.4' }
          Plug 'nvim-treesitter/nvim-treesitter'
"         Pass flags to ripgrep picker.
          Plug 'nvim-telescope/telescope-live-grep-args.nvim'

"             ',ff' to search files.
              nnoremap <leader>ff <cmd>Telescope find_files<cr>
"             ',fg' to search git files.
              nnoremap <leader>fg <cmd>Telescope git_files<cr>
"             ',fl' to live grep.
              nnoremap <leader>fs <cmd>Telescope live_grep_args<cr>
"             ',fs' to search buffers.
              nnoremap <leader>fb <cmd>Telescope buffers<cr>
"             ',fe' to live grep.
              nnoremap <leader>fe :lua require('telescope.builtin').live_grep_args({grep_open_files=true})<CR>
"             ',fw' to search projects.
              nnoremap <leader>fw :lua require'telescope'.extensions.projects.projects{}<CR>
"             ',fv' to search terminals.
              nnoremap <leader>fv <cmd>Telescope termfinder<cr>


"             In normal mode:
"             'Ctrl+t' open entry in new tab.
"             'Ctrl+v' and 'Ctrl+x' open entry in a new vertical/horizontal split.
"             '?' view mappings.

"         Toggleterm telescope picker.
          Plug 'git@github.com:tknightz/telescope-termfinder.nvim.git'


"         Align a block around some chosen character.
          Plug 'junegunn/vim-easy-align'

"             Use EasyAlign with 'ga' in visual mode.
"             e.g. 'vipga2=' - align selected para around second equals.
              xmap ga <Plug>(EasyAlign)

"             Use EasyAlign with 'ga' in normal mode.
"             e.g. 'gaip2=' - align selected para around second equals.
              nmap ga <Plug>(EasyAlign)

"         File explorer.
          Plug 'nvim-tree/nvim-web-devicons'
          Plug 'nvim-tree/nvim-tree.lua'

"             ', ' to open and focus the tree view.
              nnoremap <leader><space> <cmd>NvimTreeFocus<cr>

"             ',w' focus on current open file in tree view.
              nnoremap <leader>w <cmd>NvimTreeFindFile<cr>

"         Comment and uncomment stuff.
          Plug 'scrooloose/nerdcommenter'

"             ',cc' to comment.
"             ',cu' to uncomment.

"         Autocomplete.
          Plug 'shougo/deoplete.nvim'

"             Run at startup.
              let g:deoplete#enable_at_startup = 1

"         Run git commands.
          Plug 'tpope/vim-fugitive'

"             ':Git <cmd>' to do your usual git shenanigans.
"
"         Surround shorttucts.
          Plug 'kylechui/nvim-surround'

"             'ysiw)' surrounds word with '('
"             'ds]' deletes square braces
"             'cs)"' changes branches with '"'


"         Puppet lang syntax highlighting.
          Plug 'rodjek/vim-puppet'


    call plug#end()


" Local Config
" =================

"   Load configuration specific to this machine.
    source ~/.config/nvim/local.vim


" Lua Start Configuration
" =======================

    :luafile ~/.config/nvim/post_init.lua

" Colorscheme
" =======================
      set termguicolors
      colorscheme NeoSolarized
