require 'rss'
require 'open-uri'
require 'nokogiri'
require 'dalli'
require 'aws-sdk-s3'
require 'dotenv'
Dotenv.load

class SeattleTimesRSSParser
  def initialize
    @excluded_categories = Set.new(['Sponsored', 'Explore', 'Diversions'])
    @included_sources = Set.new(['wordpress'])
  end

  def start
    @rss = RSS::Maker.make("2.0") do |maker|
      open'https://www.seattletimes.com/feed/' do |rss|
        feed = RSS::Parser.parse(rss)
        maker.channel.description = feed.channel.description
        maker.channel.lastBuildDate = feed.channel.lastBuildDate
        maker.channel.link = feed.channel.link
        maker.channel.title = 'The Seattle Times' #feed.channel.title # Current title in feed is 'The Seattle Times The Seattle Times'
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
    if categories_item = rss_item.categories.first
      categories = categories_item.content.split(',').map { |category| category.strip }
      return false if categories.any? {|category| @excluded_categories.include? category}
    end

    source = sourceMetaTagFor(rss_item.guid.content)
    return false unless @included_sources.include? source
    
    return true
  end
  
  def sourceMetaTagFor(link)
    source = nil
    cache = nil
    if ENV["MEMCACHED_SERVER"]
      cache = Dalli::Client.new(ENV["MEMCACHED_SERVER"].split(","), {:expires_in => 86400 })  #1 day: 60*60*24
      puts("Getting memcache for #{link}")
      source = cache.get(link)
    end
    
    unless source
      puts("Getting source by loading #{link}")
      doc = Nokogiri::HTML(open(link))
      source = doc.at('meta[name="source"]')['content']

      if cache
        puts("Setting memcache for #{link} to: #{source}")
        cache.set(link, source)
      end
    end

    return source
  end
  
  def renderRSS(uploadToS3=true)
    if uploadToS3
      s3 = Aws::S3::Resource.new
      obj = s3.bucket('rss.theappuniverse.com').object('seattletimes.xml')
      obj.put(body: @rss.to_s)
    end
    
    puts @rss
    @rss.to_s
  end
end
