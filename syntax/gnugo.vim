if exists("b:current_syntax")
  finish
endif

syn match Black "X"
syn match White "O"
syn match BlankBackground "\s"
syn match Background "\.\|+"

syn match Header "\s*A B C D E F G H J K L M N O P Q R S T"
syn match Message "\s*WHITE (O) has captured \d\+ stones"
syn match Message "\s*BLACK (X) has captured \d\+ stones"
syn match Message "^=.*"
syn match Column "\s*\d\+\s*"

hi CursorColumn
      \ ctermfg=Red ctermbg=NONE cterm=NONE
      \ guifg=Red guibg=NONE gui=NONE

hi CursorLine
      \ ctermfg=Red ctermbg=NONE cterm=NONE
      \ guifg=Red guibg=NONE gui=NONE

hi Black
      \ ctermbg=Black ctermfg=White
      \ guibg=Black guifg=White
hi White
      \ ctermbg=White ctermfg=Black
      \ guibg=White guifg=Black

hi BlankBackground
      \ ctermbg=178 ctermfg=178
      \ guibg=#dfaf00 guifg=#dfaf00
hi Background
      \ ctermbg=178 ctermfg=Black
      \ guibg=#dfaf00 guifg=Black

let b:current_syntax = "gnugo"
