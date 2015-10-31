require 'sqlite3'
require 'net/http'
require 'net/https'
require 'json'
require 'uri'

# YOU NEED TO PROVIDE YOUR FACEBOOK LOGIN AND PASSWORD FOR THIS SCRIPT TO WORK

# facebook_email =
# facebook_password =

base_uri = "https://api.gotinder.com/"

#Check if bitches.db exists
if File.exists?('bitches.db')
  # if it exists, open it
  db = SQLite3::Database.open "bitches.db"
else
  # Create a bitches database
  db = SQLite3::Database.new "bitches.db"
  rows = db.execute <<-SQL
    create table bitches (
      tinder_id integer,
      name varchar(30),
      bio text,
      birth_date integer,
      profile_pics blob
    );
  SQL
end


puts '==== SuperDater ===='
puts 'Asking permission to Zuck to make the world a better place...'

# facebook tokens
facebook_token = 'CAAGm0PX4ZCpsBAHPjhcayVBHW7QFU5fnSkyVKoGq1kVPtB5LNp4kCNosBCTwmRLFXznK59aLeNTruLQutwwzY39M7gcucqGi8l5naWq8IUbCGxd91TgEqOc0lDwFTQJZATElinruyxCZAO3AldvXX28MVfI9VnfLesDl2wC7Wpsb32KIhg9ozpRlfJBgO6BJVZBQkY2XHsgyB7ZBa3G4ZCE5yBvqLDA4kZBZCeDD3CVfiQZDZD' #get this from the api explorer or something
facebook_id = '1069585657' #your numerical facebook id
login_credentials = {'facebook_token' => facebook_token, 'facebook_id' => facebook_id}

puts 'Hoes before bros...'

# Authenticate to Tinder and return the Tinder token
def tinder_auth(fb_token, fb_id)
  # authenticate to Tinder
  auth_uri = URI("https://api.gotinder.com/auth")
  response = Net::HTTP.post_form(
    auth_uri,
    'locale' => 'fr-FR',
    'facebook_token' => fb_token,
    'facebook_id' => fb_id,
    )
  # get the tinder token and return it
  response_hash = JSON.parse(response.body)
  x_auth_token = response_hash["token"]
  x_auth_token
end

x_auth_token = tinder_auth(facebook_token, facebook_id)
# requests headers
headers = {'User-Agent' => 'Tinder/4.6.1 (iPhone; iOS 9.1; Scale/2.00)',
           'Content-Type' => 'application/json',
           'X-Auth-Token' => x_auth_token }
# AUTOLIKER
puts 'I got 99 problems but the bitches no longer are one...'
# Get a list of the bitches
while true
  uri = URI.parse(base_uri + "user/recs")
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  recs_request = Net::HTTP::Get.new(uri.path, initheader = headers)
  recs_result = https.request(recs_request)
  bitches = JSON.parse(recs_result.body)

  # Loop through all the bitches and like them
  puts '======== DICKSLAPPING BITCHES ========='
  bitches['results'].each do |bitch|
    _id = bitch['_id']
    name = bitch['name']
    bio = bitch['bio']
    birth_date = bitch['birth_date']
    profile_pics = bitch['photos'][0]['processedFiles'][0]['url']
    uri = URI.parse(base_uri + "like/" + _id)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    like_request = Net::HTTP::Get.new(uri.path, initheader = headers)
    like_result = https.request(like_request)
    puts _id + " " + name + " " + like_result.body

    # Execute inserts with parameter markers
    db.execute("INSERT INTO bitches (tinder_id, name, bio, birth_date, profile_pics)
            VALUES (?, ?, ?, ?, ?)", [_id, name, bio, birth_date, profile_pics])
    sleep 0.5
  end
end

# MESSENGER

# # Get all the matches
# uri = URI.parse(base_uri + "user/matches/")
# https = Net::HTTP.new(uri.host, uri.port)
# https.use_ssl = true
# matches_request = Net::HTTP::Get.new(uri.path, initheader = headers)
# matches_result = https.request(matches_request)
# matches = JSON.parse(matches_result.body)
# puts matches

  # Get the ones that have blank message history
  # Send first message
  # if answer
    # send second message
  # else
    # wait one day
    # send second message

# # POST call to modify profile
# uri = URI.parse(base_uri + "profile")
# https = Net::HTTP.new(uri.host, uri.port)
# https.use_ssl = true
# profile_request = Net::HTTP::Post.new(uri.path, initheader = headers)
# profile_request.body = {
#   "age_filter_min" => 18,
#   "gender" => 0,
#   "age_filter_max" => 32,
#   "distance_filter" => 14
# }.to_json
# profile_result = https.request(profile_request)
# puts profile_result.body # print the body


