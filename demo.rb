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

  get '/d3_donut' do
    d3_donut_html
  end

  websocket '/ws' do
    ws.onopen {
      if Trend::CONNECTIONS.empty?
      	@analyzer = Trend::Analyzer.new
      	@analyzer.start
      end
      Trend::CONNECTIONS.add ws
      puts "Sockets connected = #{Trend::CONNECTIONS.size}"
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
              var $tbody = $('#homer').find('tbody');
              $tbody.empty();
              if ($.isEmptyObject(data) == false) {
                $.each(data, function(word, count) {
                  $tbody.append("<tr><td>"+word+"</td><td>"+count+"</td></tr>")
                });
              } else {
                $tbody.append("<tr><td colspan='2'>Pending data...</td></tr>")
              }
            };
          </script>
        </body>
      </html>
      EOS
    end

    def d3_donut_html
      <<-EOS
      <!DOCTYPE html>
      <meta charset="utf-8">
      <style>
      
      body {
        font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
        width: 960px;
        height: 500px;
        position: relative;
      }
      svg{
        width: 100%;
        height: 100%;
      }
      path.slice{
        stroke-width:2px;
      }
      
      polyline{
        opacity: .3;
        stroke: black;
        stroke-width: 2px;
        fill: none;
      }
      
      </style>
      <body>
      Duration: 0<input type="range" id="duration" min="0" max="5000">5000 
      <br>
      <script src="http://code.jquery.com/jquery-1.11.3.min.js"></script>
      <script src="http://d3js.org/d3.v3.min.js"></script>
      <script>
      
      var svg = d3.select("body")
        .append("svg")
        .append("g")
      
      svg.append("g")
        .attr("class", "slices");
      svg.append("g")
        .attr("class", "labels");
      svg.append("g")
        .attr("class", "lines");
      
      var width = 960,
          height = 450,
        radius = Math.min(width, height) / 2;
      
      var pie = d3.layout.pie()
        .sort(null)
        .value(function(d) {
          return d.value;
        });
      
      var arc = d3.svg.arc()
        .outerRadius(radius * 0.8)
        .innerRadius(radius * 0.4);
      
      var outerArc = d3.svg.arc()
        .innerRadius(radius * 0.9)
        .outerRadius(radius * 0.9);
      
      svg.attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");
      
      var key = function(d){ return d.data.label; };
      
      var color = d3.scale.category20()
        .domain(["Lorem ipsum", "dolor sit", "amet", "consectetur", "adipisicing", "elit", "sed", "do", "eiusmod", "tempor", "incididunt"])
        //.range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);
      
      var ws = new WebSocket('ws://#{env["HTTP_HOST"]}/ws');
      ws.onmessage = function(event){
        var raw_data = $.parseJSON(event.data);
        var words = Object.keys(raw_data).map(function(w){
          return {'label': w, 'value': raw_data[w]};
        }).sort(function(a,b) {
          return d3.ascending(a.label, b.label);
        });
        change(words);
      };
      
      function mergeWithFirstEqualZero(first, second){
        var secondSet = d3.set(); second.forEach(function(d) { secondSet.add(d.label); });
      
        var onlyFirst = first
          .filter(function(d){ return !secondSet.has(d.label) })
          .map(function(d) { return {label: d.label, value: 0}; });
        return d3.merge([ second, onlyFirst ])
          .sort(function(a,b) {
            return d3.ascending(a.label, b.label);
          });
      }
      
      function change(data) {
        var duration = +document.getElementById("duration").value;
        var data0 = svg.select(".slices").selectAll("path.slice")
          .data().map(function(d) { return d.data });
        if (data0.length == 0) data0 = data;
        var was = mergeWithFirstEqualZero(data, data0);
        var is = mergeWithFirstEqualZero(data0, data);
      
        /* ------- SLICE ARCS -------*/
      
        var slice = svg.select(".slices").selectAll("path.slice")
          .data(pie(was), key);
      
        slice.enter()
          .insert("path")
          .attr("class", "slice")
          .style("fill", function(d) { return color(d.data.label); })
          .each(function(d) {
            this._current = d;
          });
      
        slice = svg.select(".slices").selectAll("path.slice")
          .data(pie(is), key);
      
        slice   
          .transition().duration(duration)
          .attrTween("d", function(d) {
            var interpolate = d3.interpolate(this._current, d);
            var _this = this;
            return function(t) {
              _this._current = interpolate(t);
              return arc(_this._current);
            };
          });
      
        slice = svg.select(".slices").selectAll("path.slice")
          .data(pie(data), key);
      
        slice
          .exit().transition().delay(duration).duration(0)
          .remove();
      
        /* ------- TEXT LABELS -------*/
      
        var text = svg.select(".labels").selectAll("text")
          .data(pie(was), key);
      
        text.enter()
          .append("text")
          .attr("dy", ".35em")
          .style("opacity", 0)
          .text(function(d) {
            return d.data.label;
          })
          .each(function(d) {
            this._current = d;
          });
        
        function midAngle(d){
          return d.startAngle + (d.endAngle - d.startAngle)/2;
        }
      
        text = svg.select(".labels").selectAll("text")
          .data(pie(is), key);
      
        text.transition().duration(duration)
          .style("opacity", function(d) {
            return d.data.value == 0 ? 0 : 1;
          })
          .attrTween("transform", function(d) {
            var interpolate = d3.interpolate(this._current, d);
            var _this = this;
            return function(t) {
              var d2 = interpolate(t);
              _this._current = d2;
              var pos = outerArc.centroid(d2);
              pos[0] = radius * (midAngle(d2) < Math.PI ? 1 : -1);
              return "translate("+ pos +")";
            };
          })
          .styleTween("text-anchor", function(d){
            var interpolate = d3.interpolate(this._current, d);
            return function(t) {
              var d2 = interpolate(t);
              return midAngle(d2) < Math.PI ? "start":"end";
            };
          });
        
        text = svg.select(".labels").selectAll("text")
          .data(pie(data), key);
      
        text
          .exit().transition().delay(duration)
          .remove();
      
        /* ------- SLICE TO TEXT POLYLINES -------*/
      
        var polyline = svg.select(".lines").selectAll("polyline")
          .data(pie(was), key);
        
        polyline.enter()
          .append("polyline")
          .style("opacity", 0)
          .each(function(d) {
            this._current = d;
          });
      
        polyline = svg.select(".lines").selectAll("polyline")
          .data(pie(is), key);
        
        polyline.transition().duration(duration)
          .style("opacity", function(d) {
            return d.data.value == 0 ? 0 : .5;
          })
          .attrTween("points", function(d){
            this._current = this._current;
            var interpolate = d3.interpolate(this._current, d);
            var _this = this;
            return function(t) {
              var d2 = interpolate(t);
              _this._current = d2;
              var pos = outerArc.centroid(d2);
              pos[0] = radius * 0.95 * (midAngle(d2) < Math.PI ? 1 : -1);
              return [arc.centroid(d2), outerArc.centroid(d2), pos];
            };      
          });
        
        polyline = svg.select(".lines").selectAll("polyline")
          .data(pie(data), key);
        
        polyline
          .exit().transition().delay(duration)
          .remove();
      };
      
      </script>
      </body>
      EOS
    end
  end
end

Rack::Handler::Puma.run Demo if __FILE__ == $0