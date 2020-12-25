autocmd BufNewFile *.sgf call gnugo#CreateSgfFile(expand('<afile>'))
autocmd BufRead    *.sgf call gnugo#ReadFile(expand('<afile>'))
