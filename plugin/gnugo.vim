if exists('g:loaded_gnugo') || &cp
  finish
endif

let g:loaded_gnugo = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

if !exists('g:gnugo_commandline_args')
  let g:gnugo_commandline_args = ''
endif

command! -nargs=* -complete=custom,s:GnugoComplete Gnugo call s:Gnugo(<q-args>)
function! s:Gnugo(params)
  if a:params =~ '^\w\+'
    let game_type = matchstr(a:params, '^\w\+')
    let args      = matchstr(a:params, '^\w\+\s*\zs.*$')
  else
    let game_type = 'black'
    let args      = ''
  endif

  call gnugo#Init('new', game_type, args)
endfunction

function! s:GnugoComplete(A, L, P)
  return join(['black', 'white', 'manual'], "\n")
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo
