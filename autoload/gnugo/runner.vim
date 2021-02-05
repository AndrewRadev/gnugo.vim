function! gnugo#runner#New(mode, args)
  if index(['black', 'white', 'manual'], a:mode) < 0
    echoerr "Game mode can only be one of: black, white, manual"
    return {}
  endif

  return {
        \ 'output':           [],
        \ 'job':              v:null,
        \ 'channel':          v:null,
        \ 'mode':             a:mode,
        \ 'commandline_args': a:args,
        \ 'finished':         v:false,
        \
        \ 'last_command':       '',
        \ 'last_response':      [],
        \ 'last_move_location': '',
        \
        \ 'Start':      function('gnugo#runner#Start'),
        \ 'Quit':       function('gnugo#runner#Quit'),
        \ 'Redraw':     function('gnugo#runner#Redraw'),
        \ 'ChangeMode': function('gnugo#runner#ChangeMode'),
        \
        \ 'Execute':    function('gnugo#runner#Execute'),
        \ 'Play':       function('gnugo#runner#Play'),
        \ 'PlayCursor': function('gnugo#runner#PlayCursor'),
        \ 'Pass':       function('gnugo#runner#Pass'),
        \ 'Cheat':      function('gnugo#runner#Cheat'),
        \ 'Undo':       function('gnugo#runner#Undo'),
        \
        \ 'Read':  function('gnugo#runner#Read'),
        \ 'Write': function('gnugo#runner#Write'),
        \
        \ 'Expect':       function('gnugo#runner#Expect'),
        \ 'HandleOutput': function('gnugo#runner#HandleOutput'),
        \ 'HandleError':  function('gnugo#runner#HandleError'),
        \ }
endfunction

function! gnugo#runner#Start() dict
  let commandline_args = g:gnugo_commandline_args.' '.self.commandline_args

  " add on_exit?
  let self.job = gnugo#async#start(self, 'gnugo '.commandline_args.' --mode gtp')
  let self.channel = self.job
endfunction

function! gnugo#runner#Quit() dict
  try
    call gnugo#async#send(self.channel, "quit")
    let [result, success] = self.Expect({
          \ 'success': '^=',
          \ 'failure': '^?'
          \ })

    if !success
      echoerr join(result, "\n")
    endif
  catch /E900:/ " Invalid channel id
    " Must have closed on us, ignore the error
  endtry
endfunction

function! gnugo#runner#ChangeMode(mode) dict
  if index(['black', 'white', 'manual'], a:mode) < 0
    echoerr "Game mode can only be one of: black, white, manual"
    return v:false
  endif

  let old_mode = self.mode
  let new_mode = a:mode

  if old_mode == 'black' && new_mode == 'white' ||
        \ old_mode == 'white' && new_mode == 'black'
    echomsg "You're changing ".old_mode." -> ".new_mode.", ".
          \ "you probably want to :Cheat once to keep the game going"
  endif

  let self.mode = new_mode
  call self.Redraw()
  return v:true
endfunction

function! gnugo#runner#Execute(command) dict
  call gnugo#async#send(self.channel, a:command)
  let [result, success] = self.Expect({
        \ 'success': '^=',
        \ 'failure': '^?'
        \ })

  if !success
    echoerr join(result, "\n")
    return v:false
  endif

  let self.last_command = a:command
  let self.last_response = result

  if a:command =~ '^\s*play'
    " we won't get the move in the result, take it from the command:
    let move_location = matchstr(a:command, 'play\s*\(black\|white\)\s*\zs\w\d\+\ze')
  else
    let move_location = substitute(result[-1], '^= \(.*\)', '\1', '')
  endif

  if move_location == 'PASS'
    let self.last_move_location = 'PASS'
  elseif move_location =~ '^[A-T]\d\+$'
    let self.last_move_location = move_location
  endif

  call self.Redraw()
  return v:true
endfunction

function! gnugo#runner#Play(location) dict
  if self.mode == 'manual'
    echomsg "In manual mode, use the :Execute command"
    return
  endif

  if self.finished
    echomsg "Game is over, but you can `ChangeMode manual` and then `:Execute` commands."
    return
  endif

  let color = self.mode
  if color == 'black'
    let other_color = 'white'
  else
    let other_color = 'black'
  endif

  return
        \ self.Execute('play '.color.' '.a:location) &&
        \ self.Execute('genmove '.other_color)
endfunction

function! gnugo#runner#Pass() dict
  if self.mode == 'manual'
    echomsg "In manual mode, use the :Execute command"
    return
  endif

  if self.finished
    echomsg "Game is over, but you can `ChangeMode manual` and then `:Execute` commands."
    return
  endif

  let color = self.mode
  if color == 'black'
    let other_color = 'white'
  else
    let other_color = 'black'
  endif

  if self.last_move_location == "PASS"
    " both have passed, time to score
    let self.finished = v:true
    call self.Redraw()
  else
    call self.Execute('genmove '.other_color)

    if self.last_move_location == "PASS"
      " both have passed, time to score
      let self.finished = v:true
      call self.Redraw()
    endif
  endif
endfunction

function! gnugo#runner#PlayCursor(color) dict
  if index(['black', 'white', 'auto'], a:color) < 0
    echoerr "Unexpected value for 'color': ".a:color
    return
  endif

  if self.finished
    echomsg "Game is over, but you can `ChangeMode manual` and then `:Execute` commands."
    return
  endif

  if self.mode == 'manual' && a:color == 'auto'
    echomsg "In manual mode, use the :Execute command or the 'o' and 'x' keys"
    return
  endif

  " Find the board line of the cursor:
  let line = matchstr(getline('.'), '^\s*\zs\d\+\ze ')
  if line == ''
    return
  endif

  " Find the board column of the cursor:
  let saved_position = winsaveview()
  let cursor_col = col('.')
  normal! G0
  if search('\%'.cursor_col.'c[A-T]', 'W') <= 0
    call winrestview(saved_position)
    return
  endif
  let column = getline('.')[col('.') - 1]
  call winrestview(saved_position)

  if self.mode == 'manual'
    " play as the appropriate color
    call self.Execute('play '.a:color.' '.column.line)
  else
    " doesn't matter what color we played as, play as the player's color:
    call self.Play(column.line)
  endif
endfunction

function! gnugo#runner#Cheat() dict
  if self.mode == 'manual'
    echomsg "In manual mode, use the :Execute command"
    return
  endif

  if self.finished
    echomsg "Game is over, but you can `ChangeMode manual` and then `:Execute` commands."
    return
  endif

  let color = self.mode

  if color == 'black'
    let other_color = 'white'
  else
    let other_color = 'black'
  endif

  return
        \ self.Execute('genmove '.color) &&
        \ self.Execute('genmove '.other_color)
endfunction

function! gnugo#runner#Undo() dict
  if self.finished
    echomsg "Game is over, but you can `ChangeMode manual` and then `:Execute` commands."
    return
  endif

  if self.mode == 'manual'
    " undo the last move
    return self.Execute('undo')
  else
    " undo both computer and player move
    return
          \ self.Execute('undo') &&
          \ self.Execute('undo')
  endif
endfunction

function! gnugo#runner#Redraw() dict
  call gnugo#async#send(self.channel, "showboard")
  let [board, _] = self.Expect({
        \ 'success': 'A B C',
        \ 'count': 2
        \ })

  if board[0] == ''
    let board = board[1:]
  endif

  let output = []

  if self.finished
    call gnugo#async#send(self.channel, "final_score")
    let [raw_result, _] = self.Expect({'success': '^='})
    let result = matchstr(raw_result[-1], '^= \zs.*')

    let [color_code, score] = split(result, '+')
    if color_code == 'B'
      let winning_color = 'Black'
    elseif color_code == 'W'
      let winning_color = 'White'
    else
      let winning_color = '???'
    endif

    call extend(output, [
          \ '=',
          \ '= Final result: '.winning_color.' wins by '.score.' points',
          \ '=',
          \ ])
  else
    call extend(output, [
          \ '= Last command:  '.self.last_command,
          \ '= Last location: '.self.last_move_location,
          \ '= Game Mode:     '.self.mode,
          \ ])
  endif

  call extend(output, board)

  let saved_view = winsaveview()
  normal! ggdG
  call setline(1, output)
  normal! gg
  set nomodified
  call winrestview(saved_view)
endfunction

function! gnugo#runner#HandleOutput(lines) dict
  let lines = a:lines

  if has('nvim') && len(self.output) > 0
    " then the last line of the output is going to be incomplete:
    let self.output[-1] .= lines[0]
    let lines = lines[1:]
  endif

  call extend(self.output, lines)
endfunction

function! gnugo#runner#HandleError(lines) dict
  if has('nvim') && a:lines == ['']
    " it's fine, this is a signal for EOF
    return
  endif

  echoerr "Error: ".string(a:lines)
endfunction

function! gnugo#runner#Expect(params) dict
  let pattern = a:params.success

  " how do we know there's an error?
  if has_key(a:params, 'failure')
    let failure_pattern = a:params.failure
  else
    let failure_pattern = ''
  endif

  " which encounter of the pattern to match:
  if has_key(a:params, 'count')
    let expected_match_count = a:params.count
  else
    let expected_match_count = 1
  endif

  let current_offset = 0
  let found_offset   = -1
  let result         = []

  while expected_match_count > 0
    " being updated asynchronously:
    let content_lines = self.output[current_offset:]

    let index = 0
    for line in content_lines
      if line =~ pattern
        " we have a match, take everything up to the line, leave everything
        " afterwards
        let found_offset = current_offset + index
        let expected_match_count -= 1
        break
      endif

      if failure_pattern != '' && line =~ failure_pattern
        " we have a match for a failure, take the contents and bail out:
        let found_offset = current_offset + index
        let result = self.output[0:found_offset]
        " clear what we've found
        let self.output = self.output[(found_offset + 1):]
        return [result, 0]
      endif

      let index += 1
    endfor

    " for the next scan, just look at everything after the offset
    let current_offset = found_offset + 1
    sleep 10m
  endwhile

  let result = self.output[0:found_offset]
  " clear what we've found
  let self.output = self.output[(found_offset + 1):]

  return [result, 1]
endfunction

function! gnugo#runner#Write(filename) dict
  if self.Execute('printsgf '.a:filename)
    if expand('%') == ''
      exe 'file '.a:filename
    endif
  endif
endfunction

function! gnugo#runner#Read(filename) dict
  if self.Execute('loadsgf '.a:filename)
    if expand('%') == ''
      exe 'file '.a:filename
    endif

    let color_pattern =  '=\s*\zs\%(black\|white\)$'

    if self.last_response[-1] =~ color_pattern
      let player_color = matchstr(self.last_response[-1], color_pattern)
      call self.ChangeMode(player_color)
    endif
  endif
endfunction
