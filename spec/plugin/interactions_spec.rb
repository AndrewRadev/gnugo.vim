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
end
