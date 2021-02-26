require 'uri'
require 'net/http'
require 'json'

module Goggleme
  class Client
    def self.token(code_verifier, code)
      base = "https://oauth2.googleapis.com/token"
      params = {
          grant_type: 'authorization_code',
          code_verifier: code_verifier,
          code: code,
          client_id: '591376582274-ctrjhsj8fjjhn4pk1rknfvcfhrcc3af7.apps.googleusercontent.com',
          client_secret: 'cZAXyEkeV9kZNmDQyZsNLHaj',
          redirect_uri: 'http://localhost:9876/authorize',
      }
      url = URI(base)

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request["content-type"] = 'application/x-www-form-urlencoded'
      request.body = params.map { |x, v| "#{x}=#{v}" }.reduce { |x, v| "#{x}&#{v}" }
      response = http.request(request)

      if response.code == '200'
        JSON.parse(response.body)
      else
        raise(Error, "Invalid token response, got #{response.code}")
      end
    end

    def self.user(token)
      url = URI("https://www.googleapis.com/oauth2/v1/userinfo?alt=json")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(url)
      request["Authorization"] = "Bearer #{token}"
      response = http.request(request)

      if response.code == '200'
        JSON.parse(response.body)
      else
        raise(Error, "Invalid token response, got #{response.code}")
      end
    end
  end
end
