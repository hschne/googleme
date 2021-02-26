# frozen_string_literal: true

require_relative "gitme/version"
require_relative "gitme/server"
require_relative "gitme/browser"
require_relative "gitme/client"
require_relative "gitme/store"

require 'thor'
require 'securerandom'
require 'digest'
require 'amazing_print'

module Gitme
  class Error < Thor::Error; end

  class Main < Thor
    def self.exit_on_failure?
      true
    end

    desc 'login', 'Log into GitHub'

    def login
      state = SecureRandom.base64(16)
      code_verifier = generate_code_verifier
      code_challenge = generate_pkce_challenge(code_verifier)

      server = Thread.new do
        Server.new(state).start
      end

      browser = Browser.new(code_challenge,state)
      say "Opening browser...\n\n#{browser.url}\n\n"
      browser.open

      server.join
      code = server.value
      data = Client.token(code_verifier, code)
      Store.new.put(data)
      say 'Successfully logged in!'
    end

    desc 'user', 'Get data for the currently logged in user'
    def user
      data = Store.new.get
      raise(Error, 'No access token found, please login first') unless data

      access_token = data['access_token']
      response = Client.user(access_token)
      ap response
    end

    no_commands do
      def generate_code_verifier
        urlsafe_base64(SecureRandom.base64(64))
      end

      def generate_pkce_challenge(code_verifier)
        urlsafe_base64(Digest::SHA2.base64digest(code_verifier))
      end

      def urlsafe_base64(base64_str)
        base64_str.tr("+/", "-_").tr("=", "")
      end
    end
  end
end
