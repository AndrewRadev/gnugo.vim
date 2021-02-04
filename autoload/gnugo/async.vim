function! gnugo#async#start(command, options) abort
  let job = job_start(a:command, {
        \ 'out_cb': get(a:options, 'on_stdout', ''),
        \ 'err_cb': get(a:options, 'on_stderr', ''),
        \ })
  return job_info(job).channel
endfunction

function! gnugo#async#send(channel, command) abort
  return ch_sendraw(a:channel, a:command . "\n")
endfunction
