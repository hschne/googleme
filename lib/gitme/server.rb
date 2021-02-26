require 'socket'
require 'uri'
require 'cgi'

module Gitme
  class Server
    def initialize(state)
      @state = state
    end

    def start
      server = TCPServer.new 9876
      while connection = server.accept
        request = connection.gets
        data = handle(request)
        connection.puts "Hello world! The time is #{Time.now}"
        connection.close
        return data if data
      end
    end

    private

    def handle(request)
      _, full_path = request.split(' ')
      path = URI(full_path).path
      case path
      when '/authorize'
        handle_authorize(full_path)
      else
        puts 'Invalid request received'
      end
    end

    def handle_authorize(full_path)
      params = CGI.parse(URI.parse(full_path).query)
      params['code'][0]
    end
  end
end
