require "sinatra"
require "sinatra/activerecord"
require "sinatra/cross_origin"



### ALL ABOUT ADDRESS:PORT CONNECTION ###
configure { enable :cross_origin }

ALLOWED_ORIGINS = ["http://localhost:5173"] # @ telmo - for VITE

before do
  #origin = request.env["HTTP_ORIGIN"]
  #halt 404, "CROS Forbiden" unless ALLOWED_ORIGINS.include?(origin)
  #response.headers["Access-Control-Allow-Origin"] = origin
  response.headers["Access-Control-Allow-Origin"] = "*" # @ telmo - for testing with 'curl'
end

options "*" do
  response.headers["Access-Control-Allow-Methods"] = "GET, OPTIONS"
  200
end


### ALL ABOUT DATABASES ###
set :database, {
  adapter: "sqlite3",
  database: "./db/running_records.sqlite3"
}



get "/test" do
  content_type :json
  { message: "nice GET..." }.to_json
end