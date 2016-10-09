command! -buffer -nargs=* Execute call b:runner.Execute(<q-args>)
command! -buffer -nargs=* Play    call b:runner.Play(<q-args>)
command! -buffer -nargs=0 Pass    call b:runner.Pass()
command! -buffer -nargs=0 Undo    call b:runner.Undo()
command! -buffer -nargs=0 Cheat   call b:runner.Cheat()
command! -buffer -nargs=0 Redraw  call b:runner.Redraw()

command! -buffer -nargs=* -complete=custom,s:ChangeModeComplete
      \ ChangeMode call b:runner.ChangeMode(<f-args>)

function! s:ChangeModeComplete(A, L, P)
  return join(['black', 'white', 'manual'], "\n")
endfunction

nnoremap <silent> <buffer> <cr> :call b:runner.PlayCursor('auto')<cr>

nnoremap <silent> <buffer> x :call b:runner.PlayCursor('black')<cr>
nnoremap <silent> <buffer> o :call b:runner.PlayCursor('white')<cr>

autocmd BufWriteCmd <buffer> call b:runner.Write(expand('<afile>'))
autocmd QuitPre     <buffer> call b:runner.Quit()
