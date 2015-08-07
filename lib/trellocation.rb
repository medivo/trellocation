require 'trello'
require 'pry'
require 'active_support/all'

def require_all(pattern)
  Dir.glob("#{CONFIG.root}/#{pattern}/**/*.rb").sort.each { |path| require path }
end

require_relative("../config/configuration")
require_relative("../config/initializer")

require_all("lib/trellocation")
