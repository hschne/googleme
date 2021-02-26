require 'uri'
require 'net/http'
require 'json'

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

      puts response.body
      if response.code == '200'
        JSON.parse(response.body)['access_token']
      else
        raise(Error, "Invalid token response, got #{response.code}")
      end
    end

    def gh_token
      url = URI("https://#{@domain}/api/v2/users/USER_ID")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(url)
      request["authorization"] = 'Bearer YOUR_ACCESS_TOKEN'

      response = http.request(request)
      puts response.read_body
    end
  end
end
