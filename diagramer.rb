require 'sinatra'
require './src/diagram'

# Disable X-Frame-Options header to allow the page iframing
# Check this link for more details https://stackoverflow.com/a/7841082/15529889
configure do
    set :protection, :except => :frame_options
end

get '/' do
    erb :generator_template
end

get '/v1/:diagram_type/generate' do
    source = params['source']
    diagram_type = params['diagram_type']
    
    diagram = Diagram.generate_from source, diagram_type

    erb :default_template, :locals => diagram
end
