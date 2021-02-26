# frozen_string_literal: true

require_relative "gitme/version"
require_relative "gitme/server"
require_relative "gitme/browser"
require_relative "gitme/client"
require_relative "gitme/store"

require 'thor'
require 'securerandom'
require 'digest'
require 'octokit'
require 'awesome_print'

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

      puts 'Starting server...'
      server = Thread.new do
        Server.new(state).start
      end

      puts 'Waiting for browser...'
      Browser.new(code_challenge, state).open

      server.join
      code = server.value
      access_token = Client.new(code_verifier, code).token
      Store.new.put(access_token)
    end

    desc 'user', 'Get data for the currently logged in user'
    def user
      access_token = Store.new.get
      raise(Error, 'No access token found, please login first') unless access_token
      puts access_token

      client = Octokit::Client.new(access_token: access_token)
      ap client.user.to_h
    rescue Octokit::Error => e
      raise(Error, e.message)
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
