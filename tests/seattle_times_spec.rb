require '../seattle_times_rss_parser'

class FeedItem
  def initialize(filepath)
    @filepath = filepath
    feed = File.read('./feed.xml')
    item_text = File.read("./feed_items/#{filepath}")
    feed_text = feed.sub("<!-- item -->", item_text)
    @rss = RSS::Parser.parse(feed_text)
  end
  
  def item
    @rss.items.first
  end
  
  def includeItem
    basename = File.basename(@filepath,File.extname(@filepath))
    basename.split('_').last == 'true'
  end
end

describe SeattleTimesRSSParser do
  let(:rss_parser) { SeattleTimesRSSParser.new }
  
  it 'approves basic item' do
    feedItem = FeedItem.new('basic_feed_item_true.xml')
    expect(rss_parser.includeItem?(feedItem.item)).to be feedItem.includeItem
  end

  it 'approves basic item without a category' do
    feedItem = FeedItem.new('basic_feed_item_without_category_true.xml')
    expect(rss_parser.includeItem?(feedItem.item)).to be feedItem.includeItem
  end

  it 'rejects sponosored item' do
    feedItem = FeedItem.new('sponsored_feed_item_false.xml')
    expect(rss_parser.includeItem?(feedItem.item)).to be feedItem.includeItem
  end

  it 'rejects explore item' do
    feedItem = FeedItem.new('explore_feed_item_false.xml')
    expect(rss_parser.includeItem?(feedItem.item)).to be feedItem.includeItem
  end

   # When the article is loaded the source meta tag is "AP"
  it 'rejects AP item' do
    feedItem = FeedItem.new('ap_feed_item_false.xml')
    expect(rss_parser.includeItem?(feedItem.item)).to be feedItem.includeItem
  end

   # When the article is loaded the source meta tag is "NYT"
  it 'rejects NYT item' do
    feedItem = FeedItem.new('nyt_feed_item_false.xml')
    expect(rss_parser.includeItem?(feedItem.item)).to be feedItem.includeItem
  end

  it 'rejects diversions item' do
    feedItem = FeedItem.new('diversions_feed_item_false.xml')
    expect(rss_parser.includeItem?(feedItem.item)).to be feedItem.includeItem
  end

end
