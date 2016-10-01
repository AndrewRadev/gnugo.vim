" TODO (2016-09-09) Set this up when editing a go game file?
" TODO (2016-09-09) Error handling ("invalid move")
" TODO (2016-09-11) One-player mode vs two-player -- chose color,
" black/white/two-player

command! -buffer -nargs=* Execute call b:runner.Execute(<q-args>)
command! -buffer -nargs=* Play    call b:runner.Play(<q-args>)
command! -buffer -nargs=* Undo    call b:runner.Undo()
command! -buffer -nargs=0 Cheat   call b:runner.Cheat()

set cursorline cursorcolumn
set nonumber
set readonly

nnoremap <silent> <buffer> <cr> :call b:runner.PlayCursor()<cr>
nnoremap <silent> <buffer> o    :call b:runner.PlayCursor()<cr>
nnoremap <silent> <buffer> x    :call b:runner.PlayCursor()<cr>
