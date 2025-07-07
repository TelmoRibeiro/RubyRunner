require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/cross_origin'
require 'json'
require './models/running_record'


### ALL ABOUT ADDRESS:PORT CONNECTION ###
configure { enable :cross_origin }

ALLOWED_ORIGINS = ['http://localhost:5173'] # @ telmo - for VITE

before do
  #origin = request.env["HTTP_ORIGIN"]
  #halt 404, "CROS Forbiden" unless ALLOWED_ORIGINS.include?(origin)
  #response.headers["Access-Control-Allow-Origin"] = origin
  response.headers['Access-Control-Allow-Origin'] = '*' # @ telmo - for testing with 'curl'
end

options '*' do
  response.headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
  200
end


### ALL ABOUT DATABASES ###
set :database, {
  adapter:  'sqlite3',
  database: './db/running_records.sqlite3'
}



post '/add_run' do
  distance, start_time, end_time, date, location = get_parameters()
  error_on_missing_parameters(distance, start_time, end_time, date, location)
  start_time, end_time = parse_times(start_time, end_time)
  duration = (end_time - start_time).to_i
  pace     = (duration / distance.to_f).round
  RunningRecord.create(
    distance:   distance.to_f,
    start_time: start_time.strftime('%H:%M:%S'),
    end_time:   end_time.strftime('%H:%M:%S'),
    duration:   duration,
    pace:       pace,
    date:       date,
    location:   location
  )
  content_type :json
  status 200
  { message: 'Run Added Successfully' }.to_json
end

def get_parameters()
  request.body.rewind
  begin
    payload = JSON.parse(request.body.read)
  rescue JSON::ParserError => error
    halt 400,
      { 'Content-Type' => 'application/json'},
      { error: "Invalid JSON: #{error.message}" }.to_json
  end
  distance   = payload['distance']
  start_time = payload['start_time']
  end_time   = payload['end_time']
  date       = payload['date']
  location   = payload['location']
  [distance, start_time, end_time, date, location]
end

def error_on_missing_parameters(distance, start_time, end_time, date, location)
  missing_parameters = []
  missing_parameters << 'distance'   if distance.nil?
  missing_parameters << 'start_time' if start_time.nil?
  missing_parameters << 'end_time'   if end_time.nil?
  missing_parameters << 'date'       if date.nil?
  missing_parameters << 'location'   if location.nil?
  unless missing_parameters.empty?
    halt 400,
      { 'Content-Type' => 'application/json' },
      { error: "Missing Parameters: #{missing_parameters.join(', ')}" }.to_json
  end
end

def parse_times(start_time, end_time)
  begin
    parsed_start_time = Time.parse(start_time)
    parsed_end_time   = Time.parse(end_time)
    if parsed_start_time > parsed_end_time
      halt 400,
        { 'Content-Type' => 'application/json' },
        { error: 'start_time after the end_time? you a time traveler man?' }.to_json
    end
  rescue ArgumentError
    halt 400,
      { 'Content-Type' => 'application/json' },
      { error: 'Unexpected Time Format' }.to_json
  end
  [parsed_start_time, parsed_end_time]
end