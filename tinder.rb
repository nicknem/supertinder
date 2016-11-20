require 'sqlite3'
require 'net/http'
require 'net/https'
require 'json'
require 'uri'
require 'watir-webdriver'
require 'io/console'
require_relative 'functions'

BASE_URI = "https://api.gotinder.com/".freeze

puts "########################"
puts "Welcome to SuperTinder"
puts "########################"

puts "Paste in your Facebook ID:"
fb_token = gets.chomp
puts 'Paste your Facebook Auth Token:'
fb_id = gets.chomp

x_auth_token = get_tinder_auth_token(fb_token, fb_id, BASE_URI)
headers = {'User-Agent' => 'Tinder/4.6.1 (iPhone; iOS 9.1; Scale/2.00)', 'Content-Type' => 'application/json', 'X-Auth-Token' => x_auth_token }

while true
  begin
    chicks = list_chicks(BASE_URI, headers)
    autolike(chicks, BASE_URI, headers)
  rescue Exception => e
   puts "Something went wrong..."
  end
  sleep 10000
end
