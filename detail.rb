require 'nokogiri'
require 'open-uri'
require 'mongoid'
#require 'ruby-progressbar'

ENV['MONGOID_ENV'] = 'development'
Mongoid.load!(File.expand_path('../mongoid.yml', __FILE__))



# Define some db modul.

class CrawlStatus
  # Storge the info which game was been crawl.
  include Mongoid::Document
  field :title, type: String
end



# Real show begin here.

game_url = Nokogiri::HTML(open('http://tvgdb.duowan.com/ps4/18025/3.html'))
game_img = game_url.css('#main dt span img')[0]['src']
game_title_en = game_url.css('#main dd ul li b')[0].text
game_title_jp = game_url.css('#main dd ul li b')[1].text
game_dev_co = game_url.css('#main dd ul li b')[3].text
game_laugh_co = game_url.css('#main dd ul li b')[4].text
game_genre = game_url.css('#main dd ul li b')[7].text
game_desc = game_url.css('#main dd .game-text p').text.delete!("\n").delete!("\t").rstrip
gamespot_point = nil
fami_point = nil

if game_url.css('#main .extra span')
  if (game_url.css('#main .extra span')[0].text == "FAMI评分")
    fami_point = game_url.css('#main .extra strong a')[0].text
  elsif (game_url.css('#main .extra span')[0].text == "GAMESPOT评分")
    gamespot_point = game_url.css('#main .extra strong a')[0].text
  end
  
  if game_url.css('#main .extra span')[1]
    gamespot_point = game_url.css('#main .extra strong a')[1].text
  end
end



puts "GAME_IMG: #{game_img}"
puts "GAME_TITLE_EN: #{game_title_en}"
puts "GAME_TITLE_JP: #{game_title_jp}"
puts "GAME_DEV_CO: #{game_dev_co}"
puts "GAME_LAUGH_CO: #{game_laugh_co}"
puts "GAME_DESC: #{game_desc}"
puts "GAME_GENRE: #{game_genre}"
puts "GAME_GAMESPOT_POINT: #{gamespot_point}" if gamespot_point
puts "GAME_FAMI_POINT: #{fami_point}" if fami_point


# Let's crawl it, wolverine.

#new_crawl_list = Wolverine.new("ps4")
#new_crawl_list.crawl_it