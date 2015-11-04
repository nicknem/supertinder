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
def tinder_auth(fb_token, fb_id, base_uri)
  # authenticate to Tinder
  auth_uri = URI.parse(base_uri + "auth")
  response = Net::HTTP.post_form(
    auth_uri,
    'locale' => 'fr-FR',
    'facebook_token' => fb_token,
    'facebook_id' => fb_id,
    )
  # get the tinder token and return it
  response_hash = JSON.parse(response.body)
  response_hash["token"]
end

def get_call(uri, headers)
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  recs_request = Net::HTTP::Get.new(uri.path, initheader = headers)
  response = https.request(recs_request)
  response_hash = JSON.parse(response.body)
  response_hash
end

def get_updates(headers)
  uri = URI.parse("https://api.gotinder.com/updates")
  get_call(uri, headers)
end

# Get a list of the bitches
def list_bitches(base_uri, headers)
  uri = URI.parse(base_uri + "user/recs")
  get_call(uri, headers)
end

def autolike(bitches, base_uri, headers)
  db = open_database
  bitches['results'].each do |bitch|
    # Useful data on bitches
    _id = bitch['_id']
    name = bitch['name']
    bio = bitch['bio']
    birth_date = bitch['birth_date']
    profile_pics = bitch['photos'][0]['processedFiles'][0]['url']
    liked_date = Time.now.to_s
    uri = URI.parse(base_uri + "like/" + _id)
    # Get call to like bitches
    like_result = get_call(uri, headers)
    puts "#{_id}- #{name}: #{like_result.to_s}"
    # Insert bitches in the database
    db.execute("INSERT INTO bitches (tinder_id, name, bio, birth_date, profile_pics, liked_date)
              VALUES (?, ?, ?, ?, ?, ?)", [_id, name, bio, birth_date, profile_pics, liked_date])
    sleep 0.5
  end
end

def update_profile
  # Change the profile
  uri = URI.parse("https://api.gotinder.com/profile")
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  recs_request = Net::HTTP::Post.new(uri.path, initheader = headers)
  recs_request.body = {
    "gender" => 1
  }.to_json
  response = https.request(recs_request)
  puts response.body
end

