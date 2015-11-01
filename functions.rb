# THIS IS A FILE CONTAINING THE FUNCTIONS
require 'sqlite3'
require 'net/http'
require 'net/https'
require 'json'
require 'uri'

# Open the database
def open_database
  # Check if the database exists
  if File.exists?('bitches.db')
    db = SQLite3::Database.open "bitches.db"
    db
  else
    # Create a bitches database
    db = SQLite3::Database.new "bitches.db"
    rows = db.execute <<-SQL
      create table bitches (
        tinder_id integer,
        name varchar(30),
        bio text,
        birth_date integer,
        profile_pics blob,
        liked_date blob
      );
    SQL
    db
  end
end

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

# Get a list of the bitches
def list_bitches(base_uri, headers)
  uri = URI.parse(base_uri + "user/recs")
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  recs_request = Net::HTTP::Get.new(uri.path, initheader = headers)
  recs_result = https.request(recs_request)
  bitches = JSON.parse(recs_result.body)
  bitches
end

def autolike(bitches, base_uri, headers)
  db = open_database
  bitches['results'].each do |bitch|
  _id = bitch['_id']
  name = bitch['name']
  bio = bitch['bio']
  birth_date = bitch['birth_date']
  profile_pics = bitch['photos'][0]['processedFiles'][0]['url']
  liked_date = Time.now.to_s
  uri = URI.parse(base_uri + "like/" + _id)
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  like_request = Net::HTTP::Get.new(uri.path, initheader = headers)
  like_result = https.request(like_request)
  puts _id + " " + name + " " + like_result.body
  # Execute inserts with parameter markers
  db.execute("INSERT INTO bitches (tinder_id, name, bio, birth_date, profile_pics, liked_date)
            VALUES (?, ?, ?, ?, ?, ?)", [_id, name, bio, birth_date, profile_pics, liked_date])
  sleep 0.5
  end
end


