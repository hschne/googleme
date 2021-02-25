# frozen_string_literal: true

require_relative "gitme/version"
require_relative "gitme/server"

require 'thor'

module Gitme
  class Error < StandardError; end
  # Your code goes here...

  class Main < Thor
    desc "hello NAME", "say hello to NAME"

    def hello(name)
      puts "Hello #{name}"
    end

    desc 'server', 'server'
    def server
      Server.new.start
    end

    def login
    end

    def profile

    end
  end
end
