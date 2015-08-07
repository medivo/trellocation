require 'bundler/setup'

Dir["lib/tasks/**/*.rake"].each { |ext| load ext }

desc "launches pry with environment loaded"
task :console do
  sh "pry -r ./lib/trellocation"
end
