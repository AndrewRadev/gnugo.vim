function! gnugo#Init(edit_command, game_type, args)
  let runner = gnugo#runner#New(a:game_type, a:args)
  if empty(runner)
    return
  endif

  if a:edit_command != ''
    exe a:edit_command
    25wincmd _
  endif

  set filetype=gnugo
  set buftype=acwrite
  set nonumber

  let b:runner = runner
  call b:runner.Start()
  call b:runner.Redraw()

  " position cursor in a sensible place, at D4
  call cursor(21, 10)
endfunction

function! gnugo#CreateSgfFile(filename)
  if g:gnugo_new_game_from_file == "always" ||
        \ (
        \   g:gnugo_new_game_from_file == "ask" &&
        \   confirm("Start new GnuGo game?", "&Yes\n&No") == 1
        \ )
    call gnugo#Init('', 'manual', '')
    call b:runner.Write(a:filename)
  endif
endfunction

function! gnugo#ReadSgfFile(filename)
  if join(getline(1, 5), "\n") !~ 'GN[GNU Go'
    return
  endif

  if g:gnugo_load_game_from_file == "always" ||
        \ (
        \   g:gnugo_load_game_from_file == "ask" &&
        \   (confirm("Load saved GnuGo game?", "&Yes\n&No") == 1)
        \ )
    call gnugo#Init('', 'manual', '')
    call b:runner.Read(a:filename)
  endif
endfunction
