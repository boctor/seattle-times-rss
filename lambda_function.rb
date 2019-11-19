require './seattle_times_rss_parser'

def lambda_handler(event:, context:)
  parser = SeattleTimesRSSParser.new
  parser.start()
  { statusCode: 200, body: parser.renderRSS() }
end
