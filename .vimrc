set nocompatible                                           
set t_Co=16                                                
syntax on                                                  
set background=dark " dark | light "                       
colorscheme solarized                                      
call togglebg#map("<F5>")
filetype plugin on

set cursorline
set colorcolumn=80



" Unmap the Arrow Keys
no <down> <Nop>
no <left> <Nop>
no <right> <Nop>
no <up> <Nop>

ino <down> <Nop>
ino <left> <Nop>
ino <right> <Nop>
ino <up> <Nop>

vno <down> <Nop>
vno <left> <Nop>
vno <right> <Nop>
vno <up> <Nop>

"============ Custom Mappings ==============
" general
nmap <C-Tab> :tabnext<CR>
nmap <C-S-Tab> :tabprevious<CR>
map <C-S-Tab> :tabprevious<CR>
map <C-Tab> :tabnext<CR>
imap <C-Tab> <ESC>:tabnext<CR>
imap <C-S-Tab> <ESC>:tabprevious<CR>
noremap <F7> :set expandtab!<CR>


