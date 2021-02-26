# frozen_string_literal: true

require_relative "lib/gitme/version"

Gem::Specification.new do |spec|
  spec.name          = "gitme"
  spec.version       = Gitme::VERSION
  spec.authors       = ["hschne"]
  spec.email         = ["hans.schnedlitz@gmail.com"]

  spec.summary       = "Gitme demonstrates how to use Oauth in a Thor CLI app."
  spec.description   = "A demo application for oauth"
  spec.homepage      = "https://github.com/hschne/gitme"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/hschne/gitme"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 1.1"
  spec.add_dependency "launchy", "~> 2.5"
  spec.add_dependency "jwt", "~> 2.2"
  spec.add_dependency "amazing_print", "~> 1.2"
end
