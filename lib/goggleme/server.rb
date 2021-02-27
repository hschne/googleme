# frozen_string_literal: true

require 'socket'
require 'uri'
require 'cgi'

module Goggleme
  class Server
    def initialize(state)
      @state = state
    end

    def start
      server = TCPServer.new 9876
      while connection = server.accept
        request = connection.gets
        data = handle(request)
        connection.puts 'OAuth request received. You can close this window now.'
        connection.close
        return data if data
      end
    end

    private

    def handle(request)
      _, full_path = request.split(' ')
      path = URI(full_path).path

      handle_authorize(full_path) if path == '/authorize'
    end

    def handle_authorize(full_path)
      params = CGI.parse(URI.parse(full_path).query)
      raise(Error, 'Invalid oauth request received') if @state != params['state'][0]

      params['code'][0]
    end
  end
end
