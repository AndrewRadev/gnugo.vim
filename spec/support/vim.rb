module Support
  module Vim
    def buffer_contents
      vim.
        echo(%<join(getbufline('%', 1, '$'), "\n")>).
        gsub(/\s*$/, '')
    end
  end
end
