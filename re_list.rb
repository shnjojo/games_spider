require 'open-uri'
require 'nokogiri'

ps3_url = Nokogiri::HTML(open('http://tvgdb.duowan.com/ps3'))
puts ps3_url