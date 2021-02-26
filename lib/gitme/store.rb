require 'json'

module Gitme
  class Store
    def initialize
      @path = File.join(Dir.home, '.gitme')
    end

    def put(token)
      File.open(@path, "w") do |f|
        f.write token
      end
    end

    def get
      return unless File.file?(@path)

      File.read(@path)
    end
  end
end
