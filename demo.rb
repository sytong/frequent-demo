require 'sinatra'
require 'rack/handler/puma'
require 'sinatra/hijacker'

require_relative 'lib/trend'

class Demo < Sinatra::Base

  register Sinatra::Hijacker

  get '/' do
    "Hello"
  end

  websocket '/ws' do
    ws.onopen { 
      puts Trend::CONNECTIONS
      if Trend::CONNECTIONS.empty?
      	puts "Create Analyzer"
      	@analyzer = Trend::Analyzer.new
      	@analyzer.start
      end
      Trend::CONNECTIONS.add ws 
    }
    ws.onmessage{|msg| puts msg}
  end
end

Rack::Handler::Puma.run Demo if __FILE__ == $0