require 'sinatra'
require './seattle_times_rss_parser'

get '/', :provides => ['rss', 'atom', 'xml'] do
  parser = SeattleTimesRSSParser.new
  parser.start()
  parser.renderRSS()
end
