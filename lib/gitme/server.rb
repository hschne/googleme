require 'socket'
require 'uri'
require 'cgi'

module Gitme
  class Server
    def start
      server = TCPServer.new 9876

      puts 'Waiting for request...'
      while connection = server.accept
        request = connection.gets
        handle(request)
        connection.puts "Hello world! The time is #{Time.now}"
        connection.close
      end
    end

    private

    def handle(request)
      method, full_path = request.split(' ')
      path = URI(full_path).path
      case path
      when '/authorize'
        handle_authorize(full_path)
      else
        puts 'nothing'
      end
    end

    def handle_authorize(full_path)
      params = CGI.parse(URI.parse(full_path).query)
      puts "Path is #{full_path}"
      puts "Params is #{params}"
    end
  end
end
