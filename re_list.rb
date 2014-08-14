require 'open-uri'
require 'nokogiri'
require 'digest'

seeder_url = Nokogiri::HTML(open('http://tvgdb.duowan.com/ps4'))

# Get last page url
last_page_url = seeder_url.css('.mod-page-bd a.last')[0]['href']

# Get last page num
last_page_position = last_page_url =~ /page=/
last_page_num = last_page_url[(last_page_position + 5)..-1]

# Array for all the games info on list
games_info = []

def getGamesOnSinglePage(page_num)
# Push games info to array from .item element by loop single .item

  current_page_url = 'http://tvgdb.duowan.com/ps4?page=' + page_num.to_s
  current_page = Nokogiri::HTML(open(current_page_url))
  game_info_single_page = []
  
  getEachGame(current_page)

  #return list_game_info

end


def getEachGame(current_page)
  # Get each item on current page
  
  games_on_page = []
  games_info = current_page.css('.item')
  
  games_info.each do |game_info|
    
    raw_data = {}
    
    # Get game id and game region
    game_url = game_info.css('h4 a')[0]['href']
    game_id_position = game_url =~ /ps4/
    game_id = game_url[game_id_position + 4..-8]
    game_region_position = game_url =~ /html/
    game_region = game_url[game_region_position - 2..-6]
    
    raw_data['id'] = game_id
    raw_data['region'] = game_region
    
    # Get Chinese title
    title_cn = game_info.css('h4 a').text
    title_cn_arr = title_cn.split(' ')
    region_in_title = title_cn_arr[-1]
    raw_title_cn = title_cn.delete(region_in_title).rstrip
    raw_data['title_cn'] = raw_title_cn
    
    # Get all info on single item
    infos = game_info.css('ul > li')
    
    infos.each do |info|
    # Check each label to ensure the info
    
      label = info.text.split("：").first
      content = info.text.split("：").last
      
      case label
      when "英文名称"
        raw_data['title_en'] = content
      when "开发厂商"
        raw_data['dev_co'] = content
      when "游戏类型"
        raw_data['genre'] = content
      else
        next
      end
      
    end
    
    games_on_page << raw_data
    
    print games_on_page
    
  end
end

getEachGame(Nokogiri::HTML(open('http://tvgdb.duowan.com/ps4?page=9')))

#getGamesOnSinglePage(9)

#(1..last_page_num.to_i).each do |num|
#  list_games_info = list_games_info + getGameOnList(num)
#end

#print list_games_info
#puts list_games_info.count