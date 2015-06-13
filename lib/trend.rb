require 'frequent-algorithm'
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
      puts "start"
      @thread = Thread.new {
        while true do
          FREQUENT_B.times{ @alg.process(@homer.next) }
          result = @alg.report
          puts result
          CONNECTIONS.each do |conn|
            conn.send_data result
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