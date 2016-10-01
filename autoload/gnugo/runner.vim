function! gnugo#runner#New(type)
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
        \ 'Execute': function('gnugo#runner#Execute'),
        \ 'Move':    function('gnugo#runner#Move'),
        \ 'Cheat':   function('gnugo#runner#Cheat'),
        \ 'Undo':    function('gnugo#runner#Undo'),
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
    return
  endif

  let self.last_command = a:command

  if a:command =~ '^\s*play'
    " we won't get the move in the result, take it from the command:
    let self.last_move_location = matchstr(a:command, 'play\s*\(black\|white\)\s*\zs\w\d\+\ze')
  else
    let self.last_move_location = substitute(result[-1], '^= \(.*\)', '\1', '')
  endif

  call self.Redraw()
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
        \ '= Last command: '.self.last_command,
        \ '= Location:     '.self.last_move_location,
        \ ])
  call extend(output, board)

  normal! ggdG
  call setline(1, output)
  normal! gg
  set nomodified
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