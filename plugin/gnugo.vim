if exists('g:loaded_gnugo') || &cp
  finish
endif

let g:loaded_gnugo = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

command! -nargs=* -complete=custom,s:GnugoComplete
      \ Gnugo call s:Gnugo(<f-args>)
function! s:Gnugo(...)
  if a:0 >= 1
    let game_type = a:1
  else
    let game_type = 'black'
  endif

  let runner = gnugo#runner#New(game_type)
  if empty(runner)
    return
  endif

  call gnugo#InitBuffer()

  let b:runner = runner
  call b:runner.Start()
  call b:runner.Redraw()

  " position cursor in a sensible place
  call cursor(20, 10)
endfunction
function! s:GnugoComplete(A, L, P)
  return join(['black', 'white', 'manual'], "\n")
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo
