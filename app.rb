require 'nokogiri'
require 'open-uri'
require 'mongoid'

ENV['MONGOID_ENV'] = 'development'
Mongoid.load!(File.expand_path('../mongoid.yml', __FILE__))

class Game
  include Mongoid::Document
  field :title, type: String
  field :link, type: String
  field :status, type: Boolean, default: 0
end

class FetchList
  # This class fetch each title & link of
  # the whole available games on the duowan site.
  # Then save them into db with a key-value format.
  
  # To-do: Re-spride function
  
  def initialize(console)
    # console arr can be "ps4" or "ps3" or any console on the duowan site.
    @console = console
    @fetch_list = []
    @games_data = []
  end
  
  def get_final_page
    ps3_source_url = Nokogiri::HTML(open('http://tvgdb.duowan.com/' + @console))
    ps3_page_size_url = ps3_source_url.css('.mod-page-bd a.last')
    ps3_page_size_url = ps3_page_size_url[0]['href']

    last_page = ps3_page_size_url =~ /page=/
    return (ps3_page_size_url[(last_page + 5)..-1].to_i + 1)
  end
  
  def get_all_page
    (1...get_final_page).each do |num|
      @fetch_list.push("http://tvgdb.duowan.com/" + @console + "?page=" + num.to_s)
    end
  end
  
  def get_fetch_list
    games_title = []
    games_link = []
    
    get_all_page
    
    @fetch_list.each do |link|
      page = Nokogiri::HTML(open(link))
      game_titles_perpage = page.css('h4 a')
      game_links_perpage = page.css('h4 a')
  
      game_titles_perpage.each do |game_title_perpage|
        result = game_title_perpage.text
        result_arr = result.split(' ')
        version = result_arr[-1]
        raw_title = result.delete(version).rstrip
        games_title.push(raw_title)
      end
  
      game_links_perpage.each do |game_link_perpage|
        games_link.push(game_link_perpage['href'])
      end
    end
    
    games = Hash[games_title.zip(games_link)]
    # zip() function can push 2 array dick into 1 hash hole. Amazing!
    games.each do |t, h|
      @games_data.push({title: t, link: h})
    end
  end
  
  def get_games_data
    get_fetch_list
    return @games_data
  end
  
end

fetchlist = FetchList.new("ps4")
raw_fetch_list = fetchlist.get_games_data
Game.create(raw_fetch_list)