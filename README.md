*Note: Very incomplete, still needs a lot of work*

Play gnugo in your Vim. You'll need:

- The `gnugo` command in your path
- A recent enough Vim with `+job`

![Screenshot](http://i.andrewradev.com/7bcbe35fb37eda28bc9c190ec3977666.png)

Currently, you can only run the `:Gnugo` command, which will open an empty buffer. You can then use the `:Play` command to send commands to the gnugo server, like:

``` vim
" play with black on D4
:Play play black D4

" play a computer-generated move with white
:Play genmove white
```

It's very likely to be buggy, no tests have been written yet, and it needs a more convenient interface, at time of writing. Be warned.
