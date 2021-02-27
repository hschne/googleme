# frozen_string_literal: true

require_relative 'goggleme/version'
require_relative 'goggleme/server'

require 'thor'
require 'securerandom'
require 'digest'
require 'uri'
require 'net/http'
require 'launchy'
require 'json'
require 'amazing_print'

module Goggleme
  class Error < Thor::Error; end

  class Main < Thor
    def self.exit_on_failure?
      true
    end

    def self.report_on_exception?
      false
    end

    desc 'login', 'Log in with Google'

    def login
      state = SecureRandom.base64(16)
      code_verifier = SecureRandom.base64(64).tr('+/', '-_').tr('=', '')
      code_challenge = Digest::SHA2.base64digest(code_verifier).tr('+/', '-_').tr('=', '')

      server = Thread.new do
        Thread.current.report_on_exception = false
        Server.new(state).start
      end

      params = {
        response_type: 'code',
        code_challenge_method: 'S256',
        code_challenge: code_challenge,
        client_id: '591376582274-ctrjhsj8fjjhn4pk1rknfvcfhrcc3af7.apps.googleusercontent.com',
        redirect_uri: 'http://localhost:9876/authorize',
        scope: 'https://www.googleapis.com/auth/userinfo.profile',
        state: state,
        access_type: 'offline'
      }.map { |x, v| "#{x}=#{v}" }.reduce { |x, v| "#{x}&#{v}" }

      Launchy.open("https://accounts.google.com/o/oauth2/v2/auth?#{params}") do |exception|
        raise(Error, "Attempted to open #{uri} and failed because #{exception}")
      end

      server.join

      code = server.value
      uri = URI('https://oauth2.googleapis.com/token')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri)
      request['content-type'] = 'application/x-www-form-urlencoded'
      params = {
        grant_type: 'authorization_code',
        code_verifier: code_verifier,
        code: code,
        client_id: '591376582274-ctrjhsj8fjjhn4pk1rknfvcfhrcc3af7.apps.googleusercontent.com',
        client_secret: 'cZAXyEkeV9kZNmDQyZsNLHaj',
        redirect_uri: 'http://localhost:9876/authorize'
      }.map { |x, v| "#{x}=#{v}" }.reduce { |x, v| "#{x}&#{v}" }
      request.body = params

      response = http.request(request)
      raise(Error, "Invalid token response, got #{response.code}") unless response.code == '200'

      data = JSON.parse(response.body)
      path = File.join(Dir.home, '.googleme')
      File.open(path, 'w') { |f| f.write data.to_json }

      say 'Successfully logged in!'
    end

    desc 'user', 'Retrieve user data'

    def user
      path = File.join(Dir.home, '.googleme')
      raise(Error, 'No access token found, please login first') unless File.file?(path)

      data = JSON.parse(File.read(path))
      raise(Error, 'No access token found, please login first') unless data

      access_token = data['access_token']
      uri = URI('https://www.googleapis.com/oauth2/v1/userinfo?alt=json')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{access_token}"
      response = http.request(request)
      raise(Error, "Invalid token response, got #{response.code}") unless response.code == '200'

      ap JSON.parse(response.body)
    end
  end
end
