require 'launchy'

module Gitme
  class Browser
    def initialize(code_challenge, state)
      @domain = "dev-5jpvcbdh.auth0.com"
      @client_id = 'OQs8ObNAuanvkJ84Trp2sXw7gMNTLrTE'
      @code_challenge = ''
      @state = 'testing'
      @params = {
          response_type: 'code',
          code_challenge_method: 'S256',
          code_challenge: code_challenge,
          client_id: @client_id,
          redirect_uri: 'http://localhost:9876/authorize',
          scope: 'profile',
          state: state
      }
    end

    def open
      params = @params.map{ |x,v| "#{x}=#{v}" }.reduce{|x,v| "#{x}&#{v}" }
      Launchy.open("https://#{@domain}/authorize?#{params}") do |exception|
        puts "Attempted to open #{uri} and failed because #{exception}"
      end
    end
  end
end
