function! gnugo#Init(edit_command, game_type)
  let runner = gnugo#runner#New(a:game_type)
  if empty(runner)
    return
  endif

  if a:edit_command != ''
    exe a:edit_command
    25wincmd _
  endif

  set filetype=gnugo
  set buftype=acwrite

  let b:runner = runner
  call b:runner.Start()
  call b:runner.Redraw()

  " position cursor in a sensible place
  call cursor(21, 10)
endfunction

" TODO (2016-10-01) How to figure out the color?

function! gnugo#CreateSgfFile(filename)
  call gnugo#Init('', 'manual')

  if confirm("Start new GnuGo game?")
    let b:runner.Write(a:filename)
  endif
endfunction

function! gnugo#ReadSgfFile(filename)
  if join(getline(1, 5), "\n") !~ 'GN[GNU Go'
    return
  endif

  if confirm("Load saved GnuGo game?")
    call gnugo#Init('', 'manual')
    call b:runner.Read(a:filename)
  endif
endfunction
