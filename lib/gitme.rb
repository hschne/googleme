# frozen_string_literal: true

require_relative "gitme/version"
require_relative "gitme/server"
require_relative "gitme/browser"
require_relative "gitme/client"

require 'thor'
require 'securerandom'
require 'digest'

module Gitme
  class Error < StandardError; end
  # Your code goes here...

  class Main < Thor
    desc "hello NAME", "say hello to NAME"

    def hello(name)
      puts "Hello #{name}"
    end

    desc 'login', 'Log into GitHub'
    def login
      state = SecureRandom.base64(16)
      code_verifier = SecureRandom.base64(32)
      code_challenge = Digest::SHA2.hexdigest(code_verifier)

      puts 'Starting server...'
      server = Thread.new do
        Server.new(state).start
      end

      puts 'Waiting for browser...'
      Browser.new(code_challenge, state).open

      server.join
      code = server.value
      puts server.value

      token = Client.new(code_verifier, code).token
      puts "GOT A #{token}"
    end

    def profile

    end
  end
end
