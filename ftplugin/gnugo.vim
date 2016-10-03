command! -buffer -nargs=* Execute call b:runner.Execute(<q-args>)
command! -buffer -nargs=* Play    call b:runner.Play(<q-args>)
command! -buffer -nargs=* Undo    call b:runner.Undo()
command! -buffer -nargs=0 Cheat   call b:runner.Cheat()

command! -buffer -nargs=* -complete=custom,s:ChangeModeComplete
      \ ChangeMode call b:runner.ChangeMode(<f-args>)

function! s:ChangeModeComplete(A, L, P)
  return join(['black', 'white', 'manual'], "\n")
endfunction

set nonumber

nnoremap <silent> <buffer> <cr> :call b:runner.PlayCursor()<cr>
nnoremap <silent> <buffer> o    :call b:runner.PlayCursor()<cr>
nnoremap <silent> <buffer> x    :call b:runner.PlayCursor()<cr>

autocmd BufWriteCmd <buffer> call b:runner.Write(expand('<afile>'))
