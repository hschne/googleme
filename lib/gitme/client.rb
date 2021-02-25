require 'uri'
require 'net/http'

module Gitme
  class Client
    def initialize(code_verifier, code)
      @domain = "dev-5jpvcbdh.auth0.com"
      @client_id = 'OQs8ObNAuanvkJ84Trp2sXw7gMNTLrTE'
      @params = {
          grant_type: 'authorization_code',
          code_verifier: code_verifier,
          code: code,
          client_id: @client_id,
          redirect_uri: 'http://localhost:9876/authorize',
      }
    end

    def token
      url = URI("https://#{@domain}/oauth/token")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request["content-type"] = 'application/x-www-form-urlencoded'
      request.body = @params.map{ |x,v| "#{x}=#{v}" }.reduce{|x,v| "#{x}&#{v}" }
      response = http.request(request)

      puts response.code
      puts response.message
    end
  end
end
