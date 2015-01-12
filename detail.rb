require 'nokogiri'
require 'open-uri'
require 'mongoid'
require 'ruby-progressbar'

ENV['MONGOID_ENV'] = 'development'
Mongoid.load!(File.expand_path('../mongoid.yml', __FILE__))



# Define some db modul.

class PS3CrawlPool
  include Mongoid::Document
  field :title, type: String
  field :link, type: String
  field :crawl_status, type: Boolean, default: 0
  validates :title, :uniqueness => true
end

class PS4CrawlPool
  include Mongoid::Document
  field :title, type: String
  field :link, type: String
  field :crawl_status, type: Boolean, default: 0
  validates :title, :uniqueness => true
end

class XBOX360CrawlPool
  include Mongoid::Document
  field :title, type: String
  field :link, type: String
  field :crawl_status, type: Boolean, default: 0
  validates :title, :uniqueness => true
end

class XBOXONECrawlPool
  include Mongoid::Document
  field :title, type: String
  field :link, type: String
  field :crawl_status, type: Boolean, default: 0
  validates :title, :uniqueness => true
end

class GameData
  include Mongoid::Document
  field :console, type: String
  field :title_cn, type: String
  field :title_en, type: String
  field :title_jp, type: String
  field :cover, type: String
  field :dev_co, type: String
  field :laugh_co, type: String
  field :genre, type: String
  field :desc, type: String
  field :gamespot_point, type: String
  field :fami_point, type: String
end



# Real show begin here.


def crawl_it(console)
  game_save = []
  console = console.upcase
  
  if console == "PS3"
    db = PS3CrawlPool
    all_list = PS3CrawlPool.where(crawl_status: false)
  elsif console == "PS4"
    db = PS4CrawlPool
    all_list = PS4CrawlPool.where(crawl_status: false)
  elsif console == "XBOX360"
    db = XBOX360CrawlPool
    all_list = XBOX360CrawlPool.where(crawl_status: false)
  elsif console == "XBOXONE"
    db = XBOXONECrawlPool
    all_list = XBOXONECrawlPool.where(crawl_status: false)
  end
  
  count = all_list.count
  crawlprogress = ProgressBar.create(title: "CrawlProgress", total: count)
  # Init the progress count.

  all_list.each do |item|
    item.link
    game = crawl_each_game(item.link, item.title, console)
    game_save.push(game)
    db.where(title: item.title).update(crawl_status: true)
    crawlprogress.increment
  end
  
  GameData.create(game_save)
  puts "All works has been done, Master."
end

def crawl_each_game(link, title, console)
  game_url = Nokogiri::HTML(open(link))
  game_data = {}
  
  game_data["title_cn"] = title
  game_data["console"] = console
  game_data["cover"] = game_url.css('#main dt span img')[0]['src']
  
  game_data["desc"] = nil
  game_desc = game_url.css('#main dd .game-text p')

  unless game_desc.nil?
    game_data["desc"] = game_desc.text.delete("\n").delete("\t").delete("\r").rstrip
  end
  
  game_data["gamespot_point"] = nil
  game_data["title_jp"] = nil
  game_data["fami_point"] = nil
  
  for i in 1..15
  # Check each title then suit the value in hash.
    unless game_url.css('#main dd ul li')[i-1].nil?
      
      meta = game_url.css('#main dd ul li')[i-1].text
      meta_title = meta.split("：").first
      
      case meta_title
      when "英文名称"
        game_data["title_en"] = meta.split("：").last
      when "游戏原名"
        game_data["title_jp"] = meta.split("：").last
      when "开发厂商"
        game_data["dev_co"] = meta.split("：").last
      when "发行厂商"
        game_data["laugh_co"] = meta.split("：").last
      when "游戏类型"
        game_data["genre"] = meta.split("：").last
      else
        next
      end

    else
      break
    end
  end

  # Get Gamespot and Fami point if exist
  if game_url.at_css('#main .extra span')
    if (game_url.css('#main .extra span')[0].text == "FAMI评分")
      game_data["fami_point"] = game_url.css('#main .extra strong a')[0].text
    elsif (game_url.css('#main .extra span')[0].text == "GAMESPOT评分")
      game_data["gamespot_point"] = game_url.css('#main .extra strong a')[0].text
    end
  
    if game_url.css('#main .extra span')[1]
      game_data["gamespot_point"] = game_url.css('#main .extra strong a')[1].text
    end
  end
  
  return game_data
  
end



# Let's crawl it.

puts "Which console do u like to crawl?(PS3/PS4/XBOX360/XBOXONE)"
console_input = gets.chomp.rstrip.upcase

while (console_input != "PS3") && (console_input != "PS4") && (console_input != "XBOX360") && (console_input != "XBOXONE") do
  puts "Wrong console, Only support PS3/PS4/XBOX360/XBOXONE."
  console_input = gets.chomp.rstrip.upcase
end

crawl_it(console_input)
