require 'frequent-algorithm'
require 'json'
require_relative 'homer'

module Trend
  CONNECTIONS = Set.new

  FREQUENT_N = 500
  FREQUENT_B = 100
  FREQUENT_K = 5

  class Analyzer
    def initialize(n=FREQUENT_N, b=FREQUENT_B, k=FREQUENT_K)
      @n = n
      @b = b
      @k = k

      @homer = Homer.enumerate
      @alg = Frequent::Algorithm.new(@n, @b, @k)
    end

    def start
      @thread = Thread.new {
        while true do
          begin
            FREQUENT_B.times{ @alg.process(@homer.next) }
            result = @alg.report
            puts result
            CONNECTIONS.each do |conn|
              conn.send_data result.to_json
            end
          rescue
            $stderr.puts("ERROR: #{$!}")
            $@.each do |err|
              $stderr.puts("  #{err}")
            end
          end
          sleep 5
        end
      }
    end

    def stop
      @thread.exit
    end
  end
end