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

# Real show begin here.

class Wolverine
  # This class crawl each title & link of
  # the whole available games on the duowan site.
  
  def initialize(console)
    # Console array can be "ps4" or "ps3" or any console on the duowan site.
    @console = console
    @crawl_list = []
    @games_data = []
    @games_amount = 0
  end
  
  def get_final_page
    source_url = Nokogiri::HTML(open('http://tvgdb.duowan.com/' + @console))
    final_page_url = source_url.css('.mod-page-bd a.last')
    final_page_url = final_page_url[0]['href']

    final_page = final_page_url =~ /page=/
    return (final_page_url[(final_page + 5)..-1].to_i + 1)
    # Draw out the final page number.
  end
  
  def get_all_page
    # Get every page need to be scan.
    final_page = get_final_page
    @games_amount = final_page * 5
    
    (1...final_page).each do |num|
      @crawl_list.push("http://tvgdb.duowan.com/" + @console + "?page=" + num.to_s)
    end
  end
  
  def get_crawl_list
    # According to the all page list, crawl every title and href.
    # Create a progressbar show the crawl progress.
    games_title = []
    games_link = []
    
    get_all_page
    
    crawlprogress = ProgressBar.create(title: "CrawlProgress", total: @games_amount)
    
    @crawl_list.each do |link|
      page = Nokogiri::HTML(open(link))
      game_titles_perpage = page.css('h4 a')
      game_links_perpage = page.css('h4 a')
  
      game_titles_perpage.each do |game_title_perpage|
        # Throw the version away.
        result = game_title_perpage.text
        result_arr = result.split(' ')
        version = result_arr[-1]
        raw_title = result.delete(version).rstrip
        games_title.push(raw_title)
        
        crawlprogress.increment
      end
  
      game_links_perpage.each do |game_link_perpage|
        games_link.push(game_link_perpage['href'])
      end
    end
    
    games = Hash[games_title.zip(games_link)]
    # Combine two array into one hash, then insert into db with one write.
    games.each do |t, h|
      @games_data.push({title: t, link: h})
    end
  end
  
  def crawl_it
    get_crawl_list
    
    if (@console == "PS4")
      PS4CrawlPool.create(@games_data)
    elsif (@console == "PS3")
      PS3CrawlPool.create(@games_data)
    elsif (@console == "XBOX360")
      XBOX360CrawlPool.create(@games_data)
    elsif (@console == "XBOXONE")
      XBOXONECrawlPool.create(@games_data)
    end
    puts "Wolverine: All crawl work was been done, I\'m bigger and better."
  end
  
end



# Let's crawl it, wolverine.

puts "Which console do u like to crawl?(PS3/PS4/XBOX360/XBOXONE)"
console_input = gets.chomp.rstrip.upcase

while (console_input != "PS3") && (console_input != "PS4") && (console_input != "XBOX360") && (console_input != "XBOXONE") do
  puts "Wrong console, Only support PS3/PS4/XBOX360/XBOXONE."
  console_input = gets.chomp.rstrip.upcase
end

new_crawl_list = Wolverine.new(console_input)
new_crawl_list.crawl_it