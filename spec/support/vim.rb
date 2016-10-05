module Support
  module Vim
    def get_buffer_contents
      vim.
        echo(%<join(getbufline('%', 1, '$'), "\n")>).
        gsub(/\s*$/, '')
    end

    def char_at_board(position)
      buffer_lines = get_buffer_contents.split("\n")
      buffer_line, buffer_column = position_to_buffer_coordinates(position)

      buffer_lines[buffer_line - 1][buffer_column - 1]
    end

    def go_to_board_position(position)
      buffer_line, buffer_column = position_to_buffer_coordinates(position)
      vim.command "call cursor(#{buffer_line}, #{buffer_column})"
    end

    def get_last_position
      get_buffer_contents[/^= Last location:\s+[A-T]\d+$/][/[A-T]\d+$/]
    end

    private

    def position_to_buffer_coordinates(position)
      column = position[0]
      line   = position[1, position.length]

      buffer_line = 6 + (19 - line.to_i)
      buffer_column = 4 + ('A B C D E F G H J K L M N O P Q R S T'.index(column))

      [buffer_line, buffer_column]
    end
  end
end
