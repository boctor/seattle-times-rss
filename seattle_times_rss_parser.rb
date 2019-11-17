require 'rss'
require 'open-uri'
require 'nokogiri'

class SeattleTimesRSSParser
  def start
    @rss = RSS::Maker.make("2.0") do |maker|
      open'https://www.seattletimes.com/feed/' do |rss|
        feed = RSS::Parser.parse(rss)
        maker.channel.description = feed.channel.description
        maker.channel.lastBuildDate = feed.channel.lastBuildDate
        maker.channel.link = feed.channel.link
        maker.channel.title = feed.channel.title
        maker.channel.language = feed.channel.language
        maker.channel.generator = feed.channel.generator

        feed.items.each do |rss_item|
          createItem(maker, rss_item)
        end
      end
    end
  end
  
  def createItem(maker, rss_item)
    return unless includeItem?(rss_item)
    
    maker.items.new_item do |new_item|
       rss_item.categories.each do |category|
        new_item.categories.new_category do |new_category|
          new_category.content = category.content
        end
       end
      new_item.comments = rss_item.comments
      new_item.description = rss_item.description
      new_item.guid.content = rss_item.guid.content
      new_item.dc_creator = rss_item.dc_creator
      new_item.link = rss_item.link
      new_item.title = rss_item.title
      new_item.pubDate = rss_item.pubDate
    end
  end
  
  def includeItem?(rss_item)
    # next if existing_item.description.include?("(AP)")
    # next if existing_item.description.include?("ap-org")
    # next if existing_item.dc_creator.include?("The Associated Press")
    # # next if existing_item.dc_creator.include?("Lindsey M. Roberts") //
    
    if categories_item = rss_item.categories.first
      categories = categories_item.content.split(',').map { |category| category.strip }
    
      return false if categories.include? "Sponsored"
      return false if categories.include? "Explore"
      return false if categories.include? "Diversions"
      # next if categories.include? "Nation & World"
    end


    doc = Nokogiri::HTML(open(rss_item.link))
    source = doc.at('meta[name="source"]')['content']
    # puts source
    return false unless source == "wordpress"
    # next if ["WaPo", "NYT", "AP", "TNS Explore"].include? source
    
    return true
  end
  
  def renderRSS()
    puts @rss
    @rss.to_s
  end
end
