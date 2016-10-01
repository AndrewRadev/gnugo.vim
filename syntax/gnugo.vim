if exists("b:current_syntax")
  finish
endif

syn match GnugoBlack "X"
syn match GnugoWhite "O"
syn match GnugoBlankBackground "\s"
syn match GnugoBackground "\.\|+"

syn match GnugoHeader "\s*A B C D E F G H J K L M N O P Q R S T"
syn match GnugoMessage "\s*WHITE (O) has captured \d\+ stones"
syn match GnugoMessage "\s*BLACK (X) has captured \d\+ stones"
syn match GnugoMessage "^=.*"
syn match GnugoColumn "\s*\d\+\s*"

hi GnugoBlack
      \ ctermbg=Black ctermfg=White
      \ guibg=Black guifg=White
hi GnugoWhite
      \ ctermbg=White ctermfg=Black
      \ guibg=White guifg=Black

hi GnugoBlankBackground
      \ ctermbg=178 ctermfg=178
      \ guibg=#dfaf00 guifg=#dfaf00
hi GnugoBackground
      \ ctermbg=178 ctermfg=Black
      \ guibg=#dfaf00 guifg=Black

let b:current_syntax = "gnugo"
