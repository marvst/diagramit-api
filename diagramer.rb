require 'sinatra'
require 'json'
require './src/diagram'

before do
  content_type :json    
  headers 'Access-Control-Allow-Origin' => '*', 
          'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']  
end

set :protection, false

get '/' do
  erb :generator_template
end

get '/v1/:diagram_type/generate' do
  source = Base64.decode64(params['source'])
  diagram_type = params['diagram_type']
  
  response = Diagram.generate_from source, diagram_type

  puts "Responding with #{response}"

  response.to_json
end
