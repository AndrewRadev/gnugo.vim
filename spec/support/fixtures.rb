module Support
  module Fixtures
    def savegame(filename)
      File.expand_path("../fixtures/#{filename}.sgf", File.dirname(__FILE__))
    end
  end
end
