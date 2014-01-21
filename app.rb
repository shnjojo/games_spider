require 'nokogiri'
require 'open-uri'
require 'mongoid'
require 'ruby-progressbar'

ENV['MONGOID_ENV'] = 'development'
Mongoid.load!(File.expand_path('../mongoid.yml', __FILE__))



# Define some db modul.

class PS3CrawlPool
  # Drop before init, it's just a cathe pool.
  include Mongoid::Document
  field :title, type: String
  field :link, type: String
  #index({ title: 1 }, { unique: true, drop_dups: true })
  # The motherfuck unique didn't work, shit. I googled 5 hours and found nothing.
  # If you can figure out, plz let me know.
  # email: jojo.hsuu@gmail.com
end

class PS4CrawlPool
  # Drop before init, it's just a cathe pool.
  include Mongoid::Document
  field :title, type: String
  field :link, type: String
end

class CrawlStatus
  # Storge the info which game was been crawl.
  include Mongoid::Document
  field :title, type: String
end



# Real show begin here.

class Wolverine
  # This class crawl each title & link of
  # the whole available games on the duowan site.
  # Then save them into db with a key-value format.
  # (But I can't figure out how to save the fucking title as a unique index)
  
  def initialize(console)
    # Console array can be "ps4" or "ps3" or any console on the duowan site.
    @console = console.upcase
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
    (1...get_final_page).each do |num|
      @crawl_list.push("http://tvgdb.duowan.com/" + @console + "?page=" + num.to_s)
    end
  end
  
  def get_games_amount
    # Get amount of games need to be crawl, this function just for progress.
    # Need to be rewrite. Because of the duplication crawl.
    get_all_page
    
    puts "Crawlprogress Calculating..."
    
    @crawl_list.each do |each_page|
      page = Nokogiri::HTML(open(each_page))
      game_titles_perpage = page.css('h4 a')
      
      game_titles_perpage.each do |game_title_perpage|
        @games_amount += 1
      end
    end
  end
  
  def get_crawl_list
    # According to the all page list, crawl every title and href.
    # Create a progressbar show the crawl progress.
    games_title = []
    games_link = []
    
    get_games_amount
    
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
      PS4CrawlPool.collection.drop
      PS4CrawlPool.create(@games_data)
    elsif (@console == "PS3")
      PS3CrawlPool.collection.drop
      PS3CrawlPool.create(@games_data)
    end
    puts "Wolverine: All crawl work was been done, I\'m bigger and better."
  end
  
end



# Let's crawl it, wolverine.

new_crawl_list = Wolverine.new("ps4")
new_crawl_list.crawl_it