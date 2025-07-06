require "sinatra"
require "sinatra/activerecord"
require "sinatra/cross_origin"



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


=begin
set :database, {
  adapter: "sqlite3",
  database: "./db/development.sqlite3"
}
=end



get "/test" do
  content_type :json
  { message: "nice GET..." }.to_json
end