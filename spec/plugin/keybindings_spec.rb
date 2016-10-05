require 'spec_helper'

describe "Keybindings" do
  specify "using the keyboard as black" do
    vim.command 'Gnugo black'

    expect {
      go_to_board_position('K10')
      vim.feedkeys '\<cr>'
      sleep 0.1
    }.to change { char_at_board('K10') }.from('+').to('X')

    expect {
      go_to_board_position('K11')
      vim.feedkeys 'o'
      sleep 0.1
    }.to change { char_at_board('K11') }.from('.').to('X')

    expect {
      go_to_board_position('K12')
      vim.feedkeys 'x'
      sleep 0.1
    }.to change { char_at_board('K12') }.from('.').to('X')
  end

  specify "using the keyboard as white" do
    vim.command 'Gnugo white'

    expect {
      go_to_board_position('K10')
      vim.feedkeys '\<cr>'
      sleep 0.1
    }.to change { char_at_board('K10') }.from('+').to('O')

    expect {
      go_to_board_position('K11')
      vim.feedkeys 'o'
      sleep 0.1
    }.to change { char_at_board('K11') }.from('.').to('O')

    expect {
      go_to_board_position('K12')
      vim.feedkeys 'x'
      sleep 0.1
    }.to change { char_at_board('K12') }.from('.').to('O')
  end

  specify "using the keyboard in manual mode" do
    vim.command 'Gnugo manual'

    expect {
      go_to_board_position('K10')
      vim.feedkeys '\<cr>'
      sleep 0.1
    }.not_to change { char_at_board('K10') }

    expect {
      go_to_board_position('K11')
      vim.feedkeys 'o'
      sleep 0.1
    }.to change { char_at_board('K11') }.from('.').to('O')

    expect {
      go_to_board_position('K12')
      vim.feedkeys 'x'
      sleep 0.1
    }.to change { char_at_board('K12') }.from('.').to('X')
  end
end
