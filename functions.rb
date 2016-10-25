# THIS IS A FILE CONTAINING THE FUNCTIONS
require 'sqlite3'
require 'net/http'
require 'net/https'
require 'json'
require 'uri'

# Open the database
def open_database
  # Check if the database exists
  if File.exists?('chicks.db')
    db = SQLite3::Database.open "chicks.db"
    db
  else
    # Create a chicks database
    db = SQLite3::Database.new "chicks.db"
    rows = db.execute <<-SQL
      create table chicks (
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

# Get a list of the chicks
def list_chicks(base_uri, headers)
  uri = URI.parse(base_uri + "user/recs")
  get_call(uri, headers)
end

def autolike(chicks, base_uri, headers)
  db = open_database
  chicks['results'].each do |chick|
    # Useful data on chicks
    _id = chick['_id']
    name = chick['name']
    bio = chick['bio']
    birth_date = chick['birth_date']
    profile_pics = chick['photos'][0]['processedFiles'][0]['url']
    liked_date = Time.now.to_s
    uri = URI.parse(base_uri + "like/" + _id)
    # Get call to like chicks
    like_result = get_call(uri, headers)
    puts "#{_id}- #{name}: #{like_result.to_s}"
    # Insert chicks in the database
    db.execute("INSERT INTO chicks (tinder_id, name, bio, birth_date, profile_pics, liked_date)
              VALUES (?, ?, ?, ?, ?, ?)", [_id, name, bio, birth_date, profile_pics, liked_date])
    sleep 0.5
  end
end

def update_profile # Not functional
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

