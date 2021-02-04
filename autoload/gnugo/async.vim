function! gnugo#async#start(runner, command) abort
  let runner = a:runner
  let command = a:command

  if has('nvim')
    return jobstart(a:command, {
          \ 'on_stdout': {_j, lines, _e -> runner.HandleOutput(lines)},
          \ 'on_stderr': {_j, lines, _e -> runner.HandleError(lines)},
          \ 'stdout_buffered': v:true,
          \ 'stderr_buffered': v:true,
          \ })
  else
    let job = job_start(a:command, {
          \ 'out_cb': {_j, line -> runner.HandleOutput([line])},
          \ 'err_cb': {_j, line -> runner.HandleError([line])},
          \ })
    return job_info(job).channel
  endif
endfunction

function! gnugo#async#send(channel, command) abort
  if has('nvim')
    return chansend(a:channel, a:command . "\n")
  else
    return ch_sendraw(a:channel, a:command . "\n")
  endif
endfunction
