require 'spec_helper'

describe "Finished game" do
  specify "white wins by 84 points" do
    vim.command 'Gnugo manual'
    vim.command "Execute loadsgf #{savegame('finished_game_9x9_W+84.0')}"

    vim.command 'ChangeMode black'
    vim.command 'Pass'

    expect(get_buffer_contents).to include "Final result: White wins by 84.0 points"
  end
end
