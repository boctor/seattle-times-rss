require './seattle_times_rss_parser'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :check_rss

task :check_rss do
  parser = SeattleTimesRSSParser.new
  parser.start()
  parser.renderRSS()
end