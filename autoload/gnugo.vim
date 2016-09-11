function! gnugo#InitRunner()
  return {
        \ 'output':  [],
        \ 'job':     v:null,
        \ 'channel': v:null,
        \
        \ 'Start':   function('gnugo#Start'),
        \ 'Execute': function('gnugo#Execute'),
        \
        \ 'Expect':       function('gnugo#Expect'),
        \ 'HandleOutput': function('gnugo#HandleOutput'),
        \ 'HandleError':  function('gnugo#HandleError'),
        \ }
endfunction

function! gnugo#Start() dict
  let self.job = job_start('gnugo --mode gtp', {
        \ 'out_cb': function(self.HandleOutput),
        \ 'err_cb': function(self.HandleError),
        \ })
  let self.channel = job_info(self.job).channel
endfunction

function! gnugo#Execute(move) dict
  call ch_sendraw(self.channel, a:move."\n")
  let result = self.Expect('^=', 1)
  let move_location = substitute(result[-1], '^= \(.*\)', '\1', '')

  call ch_sendraw(self.channel, "showboard\n")
  let board = self.Expect('A B C', 2)

  let output = []
  call extend(output, [
        \ '= Last command: '.a:move,
        \ '= Location:     '.move_location,
        \ ])
  call extend(output, board)

  normal! ggdG
  call setline(1, output)
  normal! gg
  set nomodified
endfunction

function! gnugo#HandleOutput(unused, line) dict
  call add(self.output, a:line)
endfunction

function! gnugo#HandleError(unused, line) dict
  echoerr "Error: ".a:line
endfunction

function! gnugo#Expect(pattern, count) dict
  let pattern = a:pattern
  " which encounter of the pattern to match:
  let encounter_count = copy(a:count)

  let current_offset = 0
  let found_offset   = -1
  let result         = []

  while encounter_count > 0
    " being updated asynchronously:
    let content_lines = self.output[current_offset:]

    let index = 0
    for line in content_lines
      if line =~ pattern
        " we have a match, take everything up to the line, leave everything
        " afterwards
        let found_offset = current_offset + index
        let encounter_count -= 1
        break
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

  return result
endfunction
