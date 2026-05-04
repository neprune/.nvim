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

"   Show line numbers (terminals are handled in post_init.lua).
    set number

"   Open new vertical splits to the right.
    set splitright

"   Open new horizontal splits below.
    set splitbelow

"   ',q' to close current split.
    nnoremap <leader>q :q<CR>
"   ',v' to open a vsplit of the current buffer.
    nnoremap <leader>v :vsplit<CR>
"   ',s' to open a horizontal split of the current buffer.
    nnoremap <leader>s :split<CR>
"   ',tn' to open a new tab.
    nnoremap <leader>tn :tabnew<CR>

"   Navigate windows with WASD ',m<direction>'.
    nnoremap <leader>mw <C-w><Up>
    nnoremap <leader>ma <C-w>h
    nnoremap <leader>ms <C-w><Down>
    nnoremap <leader>md <C-w>l

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
    nnoremap <leader>cv :vsp $MYVIMRC<CR>
"   ',cs' to open the vimrc in a in horizontal split.
    nnoremap <leader>cs :sp $MYVIMRC<CR>
"   ',ct' to open the vimrc in a in a new tab.
    nnoremap <leader>ct :tabnew $MYVIMRC<CR>
"   ',c.' to open the vimrc in the current buffer.
    nnoremap <leader>c. :e $MYVIMRC<CR>
"   ',cr' to reload the vimrc.
    nnoremap <leader>cr :source $MYVIMRC<CR>

"    Navigate errors.
     nnoremap <C-n> :cnext<CR>
     nnoremap <C-p> :cprevious<CR>
     nnoremap <leader>a :cclose<CR>

"    Copy to system clipboard.
     map yc "*y

"    No swapfiles - I tend to save regularly and don't appreciate the faff.
     set noswapfile

"    Persistent undo across sessions (stored under stdpath('state')/undo).
     set undofile

"    Auto-reload files changed outside nvim.
     set autoread

"    Case-insensitive search, unless the pattern contains a capital.
     set ignorecase
     set smartcase

"    Keep 8 lines of context above / below the cursor while scrolling.
     set scrolloff=8

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

"         Subtle vertical guides at each indent level.
          Plug 'lukas-reineke/indent-blankline.nvim'

"     Functionality
"     =============
"         Terminal mappings (',rh', ',rv', ',rt', ',rc', ',rn') live in post_init.lua.

"         Organise things into projects.
          Plug 'ahmedkhalf/project.nvim'


"         Language aware line splitting and joining.
          Plug 'AndrewRadev/splitjoin.vim'

"             'gS' to split a line.
"             'gJ' to join multiple lines.

"         IDE like tabs (configured in post_init.lua).
          Plug 'akinsho/bufferline.nvim'

"              ',1'..',9' / ',0' jump to the Nth visible buffer (renumbers as buffers close).
               nnoremap <leader>1 <cmd>BufferLineGoToBuffer 1<cr>
               nnoremap <leader>2 <cmd>BufferLineGoToBuffer 2<cr>
               nnoremap <leader>3 <cmd>BufferLineGoToBuffer 3<cr>
               nnoremap <leader>4 <cmd>BufferLineGoToBuffer 4<cr>
               nnoremap <leader>5 <cmd>BufferLineGoToBuffer 5<cr>
               nnoremap <leader>6 <cmd>BufferLineGoToBuffer 6<cr>
               nnoremap <leader>7 <cmd>BufferLineGoToBuffer 7<cr>
               nnoremap <leader>8 <cmd>BufferLineGoToBuffer 8<cr>
               nnoremap <leader>9 <cmd>BufferLineGoToBuffer 9<cr>
               nnoremap <leader>0 <cmd>BufferLineGoToBuffer 10<cr>

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
              nnoremap <leader>fl <cmd>Telescope live_grep_args<cr>
"             ',fs' to search buffers.
              nnoremap <leader>fs <cmd>Telescope buffers<cr>
"             ',fe' to live grep.
              nnoremap <leader>fe :lua require('telescope.builtin').live_grep_args({grep_open_files=true})<CR>
"             ',fw' to search projects.
              nnoremap <leader>fw :lua require'telescope'.extensions.projects.projects{}<CR>
"             ',fv' to search terminals (defined in post_init.lua).


"             In normal mode:
"             'Ctrl+t' open entry in new tab.
"             'Ctrl+v' and 'Ctrl+x' open entry in a new vertical/horizontal split.
"             '?' view mappings.


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

"             ',e' to toggle the tree view (show / hide).
              nnoremap <leader>e <cmd>NvimTreeToggle<cr>

"             ',w' focus on current open file in tree view.
              nnoremap <leader>w <cmd>NvimTreeFindFile<cr>

"         Edit your filesystem like a buffer — '-' opens parent dir.
          Plug 'stevearc/oil.nvim'

"             '-' open parent directory as an oil buffer.
"             In an oil buffer: edit lines like text (rename / delete / move), then ':w' to apply.

"         Comment / uncomment with treesitter awareness.
          Plug 'numToStr/Comment.nvim'

"             'gcc' to toggle a line comment.
"             'gc{motion}' to comment a region (e.g. 'gcip' for paragraph).
"             'gc' in visual mode to comment a selection.

"         Autocomplete (configured in post_init.lua).
          Plug 'hrsh7th/nvim-cmp'
          Plug 'hrsh7th/cmp-buffer'
          Plug 'hrsh7th/cmp-path'
          Plug 'hrsh7th/cmp-nvim-lsp'

"         LSP — ':Mason' opens the server installer UI.
          Plug 'williamboman/mason.nvim'
          Plug 'williamboman/mason-lspconfig.nvim'
          Plug 'neovim/nvim-lspconfig'

"             'gd' definition, 'gD' declaration, 'gr' references, 'gi' implementation.
"             'K' hover docs. ',lr' rename. ',la' code action. ',lf' format.
"             '[d' / ']d' previous / next diagnostic.

"         Sign-column git markers + hunk staging / blame.
          Plug 'lewis6991/gitsigns.nvim'

"             ']c' / '[c' next / previous hunk.
"             ',gs' stage hunk, ',gr' reset hunk, ',gp' preview hunk, ',gb' toggle blame.

"         Better quickfix / diagnostics UI (replaces native :copen).
          Plug 'folke/trouble.nvim'

"             ',xx' toggle (workspace diagnostics), ',xd' doc diagnostics.
"             ',xq' quickfix list, ',xl' location list.
              nnoremap <leader>xx <cmd>Trouble diagnostics toggle<cr>
              nnoremap <leader>xd <cmd>Trouble diagnostics toggle filter.buf=0<cr>
              nnoremap <leader>xq <cmd>Trouble qflist toggle<cr>
              nnoremap <leader>xl <cmd>Trouble loclist toggle<cr>

"         Popup that lists mappings when leader is held briefly.
          Plug 'folke/which-key.nvim'

"         Auto-detect indent settings (tabs / spaces / width) per file.
          Plug 'tpope/vim-sleuth'

"         Fast jump to anywhere visible. 's' jump, 'S' treesitter-aware jump.
          Plug 'folke/flash.nvim'

"         Modular utilities — using bufremove, pairs, move.
          Plug 'echasnovski/mini.nvim'

"             ',bd' delete buffer without closing the window (mini.bufremove).
"             'Alt+h/j/k/l' move line / visual selection (mini.move).
"             Auto-close brackets / quotes (mini.pairs).

"         Run git commands.
          Plug 'tpope/vim-fugitive'

"             ':Git <cmd>' to do your usual git shenanigans.
"
"         Surround shortcuts.
          Plug 'kylechui/nvim-surround'

"             'ysiw)' surrounds word with '('
"             'ds]' deletes square braces
"             'cs)"' changes braces with '"'


"         Workspaces — vim tab pages, named and persisted across nvim restarts.
"         resession persists; scope scopes the buffer list to the current tab
"         (so the bufferline at the top is per-workspace).
          Plug 'stevearc/resession.nvim'
          Plug 'tiagovla/scope.nvim'

"             ',Ws' save current tab as a workspace (prompts on first save).
"             ',Wo' picker over saved workspaces — <CR> open, <C-r> rename, <C-d> delete.
"             ',Ww' picker over open workspaces (or '+ New workspace').
"             ',Wx' close current tab (saved copy stays on disk).
"             Mappings + extension for terminals live in post_init.lua.


"         Puppet lang syntax highlighting.
          Plug 'rodjek/vim-puppet'


"         Image previews.
          Plug 'adelarsq/image_preview.nvim'

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
