# 
# This is based on the sinatra-hijacker sample
# https://github.com/minoritea/sinatra-hijacker/blob/master/sample/sinatra.rb
#

require 'sinatra'
require 'rack/handler/puma'
require 'sinatra/hijacker'

require_relative 'lib/trend'

class Demo < Sinatra::Base

  register Sinatra::Hijacker

  get '/' do
    index_html
  end

  websocket '/ws' do
    ws.onopen { 
      if Trend::CONNECTIONS.empty?
      	@analyzer = Trend::Analyzer.new
      	@analyzer.start
      end
      Trend::CONNECTIONS.add ws 
    }
    ws.onmessage{|msg| puts msg}
  end

  helpers do
    def index_html
      <<-EOS
      <html>
        <body>
          <table id="homer">
            <thead>
              <tr>
                <th>Word</th>
                <th>Count</th>
              </tr>
            </thead>
            <tbody>
            </tbody>
          </table>
          <script src="http://code.jquery.com/jquery-1.11.3.min.js"></script>
          <script>
            var ws = new WebSocket('ws://#{env["HTTP_HOST"]}/ws');
            ws.onmessage = function(event){
              var data = $.parseJSON(event.data);
              if ($.isEmptyObject(data) == false) {
                $tbody = $('#homer').find('tbody');
                $tbody.empty();
                $.each(data, function(word, count) {
                  $tbody.append("<tr><td>"+word+"</td><td>"+count+"</td></tr>")
                });
              }
            };
          </script>
        </body>
      </html>
      EOS
    end
  end
end

Rack::Handler::Puma.run Demo if __FILE__ == $0