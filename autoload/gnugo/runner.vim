function! gnugo#runner#New(type)
  if index(['black', 'white', 'manual'], a:type) < 0
    echoerr "Game type can only be one of: black, white, manual"
    return {}
  endif

  return {
        \ 'output':  [],
        \ 'job':     v:null,
        \ 'channel': v:null,
        \ 'type':    a:type,
        \
        \ 'last_command':       '',
        \ 'last_move_location': '',
        \
        \ 'Start':  function('gnugo#runner#Start'),
        \ 'Redraw': function('gnugo#runner#Redraw'),
        \
        \ 'Execute':    function('gnugo#runner#Execute'),
        \ 'Play':       function('gnugo#runner#Play'),
        \ 'PlayCursor': function('gnugo#runner#PlayCursor'),
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
  let self.job = job_start('gnugo --mode gtp', {
        \ 'out_cb': function(self.HandleOutput),
        \ 'err_cb': function(self.HandleError),
        \ })
  let self.channel = job_info(self.job).channel
endfunction

function! gnugo#runner#Execute(command) dict
  call ch_sendraw(self.channel, a:command."\n")
  let [result, success] = self.Expect({
        \ 'success': '^=',
        \ 'failure': '^?'
        \ })

  if !success
    echoerr join(result, "\n")
    return 0
  endif

  let self.last_command = a:command

  if a:command =~ '^\s*play'
    " we won't get the move in the result, take it from the command:
    let move_location = matchstr(a:command, 'play\s*\(black\|white\)\s*\zs\w\d\+\ze')
  else
    let move_location = substitute(result[-1], '^= \(.*\)', '\1', '')
  endif

  if move_location !~ '^\s*$'
    let self.last_move_location = move_location
  endif

  call self.Redraw()
  return 1
endfunction

function! gnugo#runner#Play(location) dict
  if self.type == 'manual'
    echoerr "In manual mode, use the :Execute command"
  endif

  let color = self.type

  if color == 'black'
    let other_color = 'white'
  else
    let other_color = 'black'
  endif

  return
        \ self.Execute('play '.color.' '.a:location) &&
        \ self.Execute('genmove '.other_color)
endfunction

function! gnugo#runner#PlayCursor() dict
  if self.type == 'manual'
    echoerr "In manual mode, use the :Execute command"
  endif

  " Find the board line of the cursor:
  let line = matchstr(getline('.'), '^\s*\zs\d\+\ze ')
  if line == ''
    return
  endif

  " Find the board column of the cursor:
  let saved_position = winsaveview()
  if search('\%'.col('.').'c[A-T]', 'W') <= 0
    return
  endif
  let column = getline('.')[col('.') - 1]
  call winrestview(saved_position)

  call self.Play(column.line)
endfunction

function! gnugo#runner#Cheat() dict
  if self.type == 'manual'
    echoerr "In manual mode, use the :Execute command"
  endif

  let color = self.type

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
  if self.type == 'manual'
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
  call ch_sendraw(self.channel, "showboard\n")
  let [board, _] = self.Expect({
        \ 'success': 'A B C',
        \ 'count': 2
        \ })

  if board[0] == ''
    let board = board[1:]
  endif

  let output = []
  call extend(output, [
        \ '= Last command:  '.self.last_command,
        \ '= Last location: '.self.last_move_location,
        \ ])
  call extend(output, board)

  let saved_view = winsaveview()
  normal! ggdG
  call setline(1, output)
  normal! gg
  set nomodified
  call winrestview(saved_view)
endfunction

function! gnugo#runner#HandleOutput(unused, line) dict
  call add(self.output, a:line)
endfunction

function! gnugo#runner#HandleError(unused, line) dict
  echoerr "Error: ".a:line
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
    exe 'file '.a:filename
  endif
endfunction

function! gnugo#runner#Read(filename) dict
  if self.Execute('loadsgf '.a:filename)
    exe 'file '.a:filename
  endif
endfunction
