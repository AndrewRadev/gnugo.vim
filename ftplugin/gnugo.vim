" TODO (2016-09-09) Set this up when editing a go game file?
" TODO (2016-09-09) Error handling ("invalid move")

command! -buffer -nargs=* Play call b:runner.Execute(<q-args>)
