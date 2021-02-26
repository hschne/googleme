require 'launchy'

module Goggleme
  class Browser
    def initialize(code_challenge, state)
      @base = "https://accounts.google.com/o/oauth2/v2/auth"
      @client_id = '591376582274-ctrjhsj8fjjhn4pk1rknfvcfhrcc3af7.apps.googleusercontent.com'
      @params = {
          response_type: 'code',
          code_challenge_method: 'S256',
          code_challenge: code_challenge,
          client_id: @client_id,
          redirect_uri: 'http://localhost:9876/authorize',
          scope: 'https://www.googleapis.com/auth/userinfo.profile',
          state: state,
          access_type: 'offline'
      }
    end

    def open
      Launchy.open(url) do |exception|
        raise(Error, "Attempted to open #{uri} and failed because #{exception}")
      end
    end

    def url
      params = @params.map{ |x,v| "#{x}=#{v}" }.reduce{|x,v| "#{x}&#{v}" }
      "#{@base}?#{params}"
    end
  end
end
