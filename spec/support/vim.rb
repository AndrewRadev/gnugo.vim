module Support
  module Vim
    def get_buffer_contents
      vim.
        echo(%<join(getbufline('%', 1, '$'), "\n")>).
        gsub(/\s*$/, '')
    end

    def char_at_board(position)
      buffer_lines = get_buffer_contents.split("\n")

      column = position[0]
      line   = position[1, position.length]

      buffer_line = 5 + (19 - line.to_i)
      buffer_column = 3 + ('A B C D E F G H J K L M N O P Q R S T'.index(column))

      buffer_lines[buffer_line][buffer_column]
    end

    def get_last_position
      get_buffer_contents[/^= Last location:\s+[A-T]\d+$/][/[A-T]\d+$/]
    end
  end
end
