require 'vimrunner'
require 'vimrunner/rspec'
require_relative './support/vim'
require_relative './support/fixtures'

Vimrunner::RSpec.configure do |config|
  config.reuse_server = false

  plugin_path = File.expand_path('.')

  config.start_vim do
    vim = Vimrunner.start_gvim
    vim.add_plugin(plugin_path, 'plugin/gnugo.vim')
    vim.command('let g:gnugo_new_game_from_file = "always"')
    vim.command('let g:gnugo_load_game_from_file = "always"')
    vim
  end
end

RSpec.configure do |config|
  config.include Support::Vim
  config.include Support::Fixtures
end
