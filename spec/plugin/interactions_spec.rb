require 'spec_helper'

describe "Interactions" do
  specify "using :Execute in manual mode" do
    vim.command 'Gnugo manual'

    expect {
      vim.command 'Execute play black D4'
    }.to change { char_at_board('D4') }.from('+').to('X')

    expect {
      vim.command 'Execute play white Q16'
    }.to change { char_at_board('Q16') }.from('+').to('O')
  end

  specify "using :Play as 'black'" do
    vim.command 'Gnugo black'

    vim.command 'Play D4'

    expect(char_at_board('D4')).to eq 'X'
    expect(char_at_board(get_last_position)).to eq 'O'
  end

  specify "using :Play as 'white'" do
    vim.command 'Gnugo white'

    vim.command 'Play D4'

    expect(char_at_board('D4')).to eq 'O'
    expect(char_at_board(get_last_position)).to eq 'X'
  end

  specify "using :Undo in manual mode" do
    vim.command 'Gnugo manual'

    vim.command 'Execute play black D4'
    vim.command 'Execute play white Q16'
    vim.command 'Undo'

    expect(char_at_board('D4')).to eq 'X'
    expect(char_at_board('Q16')).to eq '+'
  end

  specify "using :Undo in non-manual mode" do
    vim.command 'Gnugo'

    vim.command 'Play D4'
    vim.command 'Undo'

    expect(char_at_board('D4')).to eq '+'
    expect(char_at_board(get_last_position)).to eq '+'
  end
end
