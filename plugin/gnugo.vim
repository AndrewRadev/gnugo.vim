if exists('g:loaded_gnugo') || &cp
  finish
endif

let g:loaded_gnugo = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

command! Gnugo call s:Gnugo()
function! s:Gnugo()
  new
  set filetype=gnugo

  let b:runner = gnugo#InitRunner()
  call b:runner.Start()
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo
