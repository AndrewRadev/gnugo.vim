require 'spec_helper'

describe "Output" do
  specify "starting a new GnuGo game" do
    vim.command 'Gnugo'

    expect(get_buffer_contents).to eq normalize_string_indent(<<-EOF)
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
    EOF
  end

  specify "starting a GnuGo game with options" do
    vim.command 'Gnugo manual --boardsize=13'

    expect(get_buffer_contents).to eq normalize_string_indent(<<-EOF)
      = Last command:
      = Last location:
      = Game Mode:     manual
      =
         A B C D E F G H J K L M N
      13 . . . . . . . . . . . . . 13
      12 . . . . . . . . . . . . . 12
      11 . . . . . . . . . . . . . 11
      10 . . . + . . + . . + . . . 10
       9 . . . . . . . . . . . . . 9
       8 . . . . . . . . . . . . . 8
       7 . . . + . . + . . + . . . 7
       6 . . . . . . . . . . . . . 6
       5 . . . . . . . . . . . . . 5     WHITE (O) has captured 0 stones
       4 . . . + . . + . . + . . . 4     BLACK (X) has captured 0 stones
       3 . . . . . . . . . . . . . 3
       2 . . . . . . . . . . . . . 2
       1 . . . . . . . . . . . . . 1
         A B C D E F G H J K L M N
    EOF
  end
end
