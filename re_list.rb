require 'open-uri'
require 'nokogiri'

seeder_url = Nokogiri::HTML(open('http://tvgdb.duowan.com/ps4'))

# Get last page url
last_page_url = seeder_url.css('.mod-page-bd a.last')[0]['href']

# Get last page num by regex
last_page_position = last_page_url =~ /page=/
last_page_num = last_page_url[(last_page_position + 5)..-1]

# Array for all the games info on list
list_games_info = []

def getGameOnList(page_num)
  current_page_url = 'http://tvgdb.duowan.com/ps4' + '?page=' + page_num.to_s
  current_page = Nokogiri::HTML(open(current_page_url))
  list_game_info = []
  
  # Get game id & game region from game url
  games_url = current_page.css('h4 a')
  games_url.each do |game_url|
    game_info = {}
    game_id_position = game_url['href'] =~ /ps4/
    game_id = game_url['href'][game_id_position + 4..-8]
    game_region_position = game_url['href'] =~ /html/
    game_region = game_url['href'][game_region_position - 2..-6]
    game_info['id'] = game_id
    game_info['region'] = game_region
    
    list_game_info << game_info
  end

  return list_game_info

end

(1..last_page_num.to_i).each do |num|
  list_games_info = list_games_info + getGameOnList(num)
end

print list_games_info
puts list_games_info.count