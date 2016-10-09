Play the game of Go in your Vim! Use the cursor to move around on the board, press `<enter>` to place a stone. Ask the computer to `:Undo` your move or `:Cheat` and play for you. Save and load games by writing or editing a filename.

![Demonstration](http://i.andrewradev.com/d1f1769d687d198b89a96decba4c8952.gif)

## Requirements

This plugin requires Vim with `+job`. Vim 8 will do, but you can even use a
Vim 7.4 with a late enough patch level. Check the output of `:version`.

You'll also need GnuGo installed, since Vim simply interacts with that
program. For example, on Arch Linux, you can install it with:

```
# pacman -S gnugo
```

For other platforms, check the GnuGo project's homepage: https://www.gnu.org/software/gnugo/download.html.

## Usage

To start a new GnuGo game, just run the `:Gnugo` command. This will open a new buffer with an empty board:

```
= Last command:
= Last location:
= Game Mode:     black
=
   A B C D E F G H J K L M N O P Q R S T
19 . . . . . . . . . . . . . . . . . . . 19
18 . . . . . . . . . . . . . . . . . . . 18
17 . . . . . . . . . . . . . . . . . . . 17
16 . . . + . . . . . + . . . . . + . . . 16
15 . . . . . . . . . . . . . . . . . . . 15
14 . . . . . . . . . . . . . . . . . . . 14
13 . . . . . . . . . . . . . . . . . . . 13
12 . . . . . . . . . . . . . . . . . . . 12
11 . . . . . . . . . . . . . . . . . . . 11     WHITE (O) has captured 0 stones
10 . . . + . . . . . + . . . . . + . . . 10     BLACK (X) has captured 0 stones
 9 . . . . . . . . . . . . . . . . . . . 9
 8 . . . . . . . . . . . . . . . . . . . 8
 7 . . . . . . . . . . . . . . . . . . . 7
 6 . . . . . . . . . . . . . . . . . . . 6
 5 . . . . . . . . . . . . . . . . . . . 5
 4 . . . + . . . . . + . . . . . + . . . 4
 3 . . . . . . . . . . . . . . . . . . . 3
 2 . . . . . . . . . . . . . . . . . . . 2
 1 . . . . . . . . . . . . . . . . . . . 1
   A B C D E F G H J K L M N O P Q R S T
```

You play as black by default. To place a stone, position the cursor on an empty space (a "." or "+" character) and press the `<enter>` key. You can also use the "x" and "o" keys for the same purpose, but note that these keys have different meanings in "manual" mode. Either way, while playing as black or white, the computer will automatically play the next move with the other color.

You can also place a stone by providing its coordinates to the `:Play` command:

``` vim
:Play D4
```

If you're unsure what to do next, you can cheat and have the computer play a move for you with the `:Cheat` command:

``` vim
:Cheat
```

If you'd like to undo the last move, you can use the `:Undo` command:

``` vim
:Undo
```

While you're playing as black or white, the command will undo two moves -- the last computer move, and your last move. If you're in "manual" mode, it will only undo one move. If you'd like, you can map this command to the "u" key for this buffer, by creating the file `~/.vim/ftplugin/gnugo.vim` and mapping it only for this buffer:

``` vim
nnoremap <buffer> u :Undo<cr>
```

But be careful -- this means that, if you accidentally delete something in the buffer, you can't undo it -- the "u" key now means something else.

You can redraw the board with the `:Redraw` command:

``` vim
:Redraw
```

### Changing colors

If you'd like to play as white, you can start the game with:

``` vim
:Gnugo white
```

If you'd like to change sides halfway through, you can use the `:ChangeMode` command. Note that, if you're currently playing as black, you probably want to `:Cheat` once, since the last move was probably the computer's, and the computer should now play with your former color.

``` vim
:ChangeMode white
:Cheat
```

The same thing goes if you're playing with the white pieces and would like to switch to playing with the black ones.

### Manual mode

You can run the game in "manual" mode, which means the computer doesn't automatically play against you, and you don't automatically play with a particular color.

In this mode, you can't use `:Play` or `:Cheat`, you need to use the `:Execute` command, which lets you send commands directly to GnuGo's gtp server:

``` vim
" play as black, on D4
:Execute play black D4

" have the computer generate a move for white
:Execute genmove white
```

You can now play several times with black/white, if you're so inclined, and you can play with another person on the same machine. For convenience's sake, you can use the `o` key to play a white move, and the `x` key to play a black move (in the ASCII representation of the board, black pieces are marked with "X" and white pieces are marked as "O").

### Additional arguments

When starting the game, you can provide additional arguments that are fed directly to the gnugo command. Check `gnugo --help` for details. As an example, you can start the game with a different board size like so:

``` vim
:Gnugo black --boardsize=13
```

### Loading and saving

If you'd like to save your game, you can just `:write` the gnugo buffer to a .sgf file:

``` vim
:Gnugo black
:Play D4
:w strong_start.sgf
```

Later, you can load your game by simply editing that same .sgf file, either from Vim, with `:edit`, or from the command-line:

```
$ vim strong_start.sgf
```

You'll be asked whether you want to resume your last game. The prompt is there to allow you to directly edit the sgf file, if you need to, for whatever reason (like if you're writing this particular Vim plugin and need to see the contents of the file).

You can also edit a non-existing sgf file, and Vim will ask you if you'd like to start a new Go game with that name.

## Internals

The plugin uses Vim's job functions to spawn a `gnugo --mode gtp` process. The process is connected to the buffer, and when the buffer is closed, an autocommand sends the "quit" command to it. On my machine, this seems to keep the process around as a zombie for a few seconds, but it then gets reaped by the system. I figure it's not a big deal, so I've left it like this. If you understand processes better than me and know something different that should be done in this situation, please open an issue with your suggestion.
