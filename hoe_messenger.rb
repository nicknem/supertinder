require_relative 'tinder'
require_relative 'functions'
require 'sqlite3'
require 'net/http'
require 'net/https'
require 'json'
require 'uri'
# Don't shoot the messenger

puts "MESSENGER"

base_uri = "https://api.gotinder.com/"
facebook_token = 'CAAGm0PX4ZCpsBAHPjhcayVBHW7QFU5fnSkyVKoGq1kVPtB5LNp4kCNosBCTwmRLFXznK59aLeNTruLQutwwzY39M7gcucqGi8l5naWq8IUbCGxd91TgEqOc0lDwFTQJZATElinruyxCZAO3AldvXX28MVfI9VnfLesDl2wC7Wpsb32KIhg9ozpRlfJBgO6BJVZBQkY2XHsgyB7ZBa3G4ZCE5yBvqLDA4kZBZCeDD3CVfiQZDZD'
facebook_id = '1069585657'
puts "Logging"
# Retrieve Tinder token
x_auth_token = tinder_auth(facebook_token, facebook_id, base_uri)
# Headers for Tinder API requests
headers = {'User-Agent' => 'Tinder/4.6.1 (iPhone; iOS 9.1; Scale/2.00)',
           'Content-Type' => 'application/json',
           'X-Auth-Token' => x_auth_token }


# Get the updates
  # Send a message to new matches

def get_updates
  get_call("https://api.gotindaer.com/updates", headers)
end

