require 'nokogiri'
require 'open-uri'
require 'mongoid'
#require 'ruby-progressbar'

ENV['MONGOID_ENV'] = 'development'
Mongoid.load!(File.expand_path('../mongoid.yml', __FILE__))

# To-do:
# Data exist logic
# Some db field insert not within array-hash format

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

class GameData
  include Mongoid::Document
  field :console, type: String
  # Console table
  # 1  => PS3
  # 2  => PS4
  # 3  => XBONE
  # 4  => XB360
  field :title_cn, type: String
  field :title_en, type: String
  field :title_jp, type: String
  field :cover, type: String
  field :dev_co, type: String
  field :laugh_co, type: String
  field :genre, type: String
  # Genre table
  # 1  => 射击类
  # 2  => 动作类
  # 3  => 格斗类
  # 4  => 体育类
  # 5  => 竞速类
  # 6  => 文字类
  # 7  => 冒险类
  # 8  => 模拟类
  # 9  => 音乐类
  # 10 => 休闲益智类
  # 11 => 角色扮演类
  # 12 => 策略类
  # 13 => 模拟类
  # 14 => 其他类
  # 15 => 即时战略类
  # 16 => 卡片类
  field :desc, type: String
  field :gamespot_point, type: String
  field :fami_point, type: String
end



# Real show begin here.


def crawl_it(console)
  game_save = []
  console = console.upcase
  if console == "PS3"
    PS3CrawlPool.all.each do |item|
      item.link
      game = crawl_each_game(item.link)
      game_save.push(game)
    end
    GameData.create(game_save)
  elsif console == "PS4"
    PS4CrawlPool.all.each do |item|
      item.link
      game = crawl_each_game(item.link)
      game_save.push(game)
    end
    GameData.create(game_save)
  end
end

def crawl_each_game(link)
  game_url = Nokogiri::HTML(open(link))

  game_data = {}
  game_data["cover"] = game_url.css('#main dt span img')[0]['src']
  game_data["title_en"] = game_url.css('#main dd ul li b')[0].text
  game_data["title_jp"] = game_url.css('#main dd ul li b')[1].text
  game_data["dev_co"] = game_url.css('#main dd ul li b')[3].text
  game_data["laugh_co"] = game_url.css('#main dd ul li b')[4].text
  game_data["genre"] = game_url.css('#main dd ul li b')[7].text
  game_data["desc"] = game_url.css('#main dd .game-text p').text.delete!("\n").delete!("\t").delete!("\r").rstrip
  game_data["gamespot_point"] = nil
  game_data["fami_point"] = nil

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

crawl_it("PS4")

# Let's crawl it, wolverine.

#new_crawl_list = Wolverine.new("ps4")
#new_crawl_list.crawl_it

