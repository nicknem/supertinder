require 'sqlite3'
require 'net/http'
require 'net/https'
require 'json'
require 'uri'
require 'watir-webdriver'
require 'io/console'
require_relative 'functions'

puts "Welcome to SuperTinder"
puts "########################"

# Tinder API
base_uri = "https://api.gotinder.com/"

# -------------
# Login
# -------------
# Ask for credentials
puts "Type in your Facebook login"
myLogin = gets.chomp

# Get facebook password without displaying it
puts 'Type your Facebook password'
myPassword = STDIN.noecho(&:gets)

puts '==== FACEBOOK ===='
puts 'Fetching Facebook data...'

browser = Watir::Browser.new
puts 'Fetching your Facebook token'

# Webdriver
browser.goto 'https://www.facebook.com/dialog/oauth?client_id=464891386855067&redirect_uri=https://www.facebook.com/connect/login_success.html&scope=basic_info,email,public_profile,user_about_me,user_activities,user_birthday,user_education_history,user_friends,user_interests,user_likes,user_location,user_photos,user_relationship_details&response_type=token'
browser.text_field(:id => 'email').when_present.set myLogin
browser.text_field(:id => 'pass').when_present.set myPassword
# browser.button(:name => 'login').when_present.click
fb_token = /#access_token=(.*)&expires_in/.match(browser.url).captures[0]
puts 'My FB_TOKEN is '+fb_token

puts 'Fetching your Facebook ID...'
# browser.stop
sleep 2
browser.goto'https://www.facebook.com/profile.php'
fb_id = /fbid=(.*)&set/.match(browser.link(:class =>"profilePicThumb").when_present.href).captures[0]
puts 'My FB_ID is '+fb_id

browser.close

puts 'Asking permission to Zuck to make the world a better place...'
# Retrieve Tinder token
x_auth_token = tinder_auth(fb_token, fb_id, base_uri)
# Headers for Tinder API requests
headers = {'User-Agent' => 'Tinder/4.6.1 (iPhone; iOS 9.1; Scale/2.00)',
           'Content-Type' => 'application/json',
           'X-Auth-Token' => x_auth_token }
puts 'Hoes before bros...'

# Autoliker
while true
  bitches = list_bitches(base_uri, headers)
  # Loop through all the bitches and like them
  puts '======== DICKSLAPPING BITCHES ========='
  autolike(bitches, base_uri, headers)
end
