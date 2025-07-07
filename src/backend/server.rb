require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/cross_origin'
require 'json'
require './models/running_record'


### ALL ABOUT ADDRESS:PORT CONNECTION ###
configure { enable :cross_origin }

ALLOWED_ORIGINS = ['http://localhost:5173'] # address:port for 'VITE'

before do
  origin = request.env['HTTP_ORIGIN']
  unless ALLOWED_ORIGINS.include?(origin)
    halt 404,
      { 'Content-Type' => 'application/json' },
      { error: 'CORS Forbidden' }.to_json
  end
  response.headers["Access-Control-Allow-Origin"] = origin
  # response.headers['Access-Control-Allow-Origin'] = '*' # @ telmo - for testing with 'curl'
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
  distance, start_time, end_time, date, location = post_parameters()
  error_on_missing_parameters(
    {
      distance:   distance,
      start_time: start_time,
      end_time:   end_time,
      date:       date,
      location:   location
    },
    'Missing POST Parameters'
  )
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
    location:   location.downcase
  )
  content_type :json
  status 200
  { message: 'Run Added Successfully' }.to_json
end

get '/check_run' do
  date, location = get_parameters()
  error_on_missing_parameters(
    {
      date:     date,
      location: location
    },
    'Missing GET Parameters'
  )
  records = RunningRecord.where(date: date, location: location.downcase).to_a
  content_type :json
  status 200
  records.empty? ? {}.to_json : records.to_json
end

def post_parameters()
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

def get_parameters()
  date     = params['date']
  location = params['location']
  [date, location] 
end

def error_on_missing_parameters(labeled_parameters, error_prefix = "Missing Parameters")
  missing_parameters = []
  labeled_parameters.each do |label, parameter|
    missing_parameters << label if parameter.nil? || parameter.to_s.strip.empty?
  end
  unless missing_parameters.empty?
    halt 400,
      { 'Content-Type' => 'application/json' },
      { error: "#{error_prefix}: #{missing_parameters.join(', ')}" }.to_json
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