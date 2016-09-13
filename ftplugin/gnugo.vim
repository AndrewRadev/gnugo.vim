" TODO (2016-09-09) Set this up when editing a go game file?
" TODO (2016-09-09) Error handling ("invalid move")
" TODO (2016-09-11) One-player mode vs two-player -- chose color,
" black/white/two-player

command! -buffer -nargs=* Play call b:runner.Execute(<q-args>)
