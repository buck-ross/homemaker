" Personal VIMRC file

" Source the default VIM configuration:
source $VIMRUNTIME/defaults.vim

set autoindent
set autoprint
set noignorecase
set nomesg
set noslowopen
set noterse
set report=2
set wrapmargin=8
"
"map ; :
"map g :%
"map v ~
"map m !} fmt -c
"map T !} sort
"
set showmode

" show line numbers
set number

" set tab width = 4
set tabstop=4

" set shift width = 4 for visual mode indentation
set shiftwidth=4

" set color scheme
"color koehler

" allow arrow keys to wrap onto next line
set whichwrap+=<,>,[,]

" bracket autocomple
:inoremap {<CR> {<CR>}<C-o>O<TAB>

" enable mouse cursor
set mouse=a

" Set the configuration for secure modelines:
let g:secure_modelines_allowed_items = [
                \ "textwidth",   "tw",
                \ "softtabstop", "sts",
                \ "tabstop",     "ts",
                \ "shiftwidth",  "sw",
                \ "expandtab",   "et",   "noexpandtab", "noet",
                \ "filetype",    "ft",
                \ "foldmethod",  "fdm",
                \ "readonly",    "ro",   "noreadonly", "noro",
                \ "rightleft",   "rl",   "norightleft", "norl"
                \ ]

" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" files.
function! AppendModeline()
  let l:modeline = printf(" vim: set ts=%d sw=%d tw=%d %set :",
        \ &tabstop, &shiftwidth, &textwidth, &expandtab ? '' : 'no')
  let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
  call append(line("$"), "")
  call append(line("$"), l:modeline)
  call append(line("$"), "")
endfunction
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>

" vim: set ts=4 sw=4 tw=78 noet :

