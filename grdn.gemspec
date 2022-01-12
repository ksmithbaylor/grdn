# frozen_string_literal: true

require_relative "lib/grdn/version"

Gem::Specification.new do |spec|
  spec.name          = "grdn"
  spec.version       = Grdn::VERSION
  spec.authors       = ["Kevin Smith"]
  spec.email         = ["kevin.smith@coinbase.com"]

  spec.summary       = "This is a program for organizing seed phrases and storing them locally, encrypted"
  spec.homepage      = "https://github.cbhq.net/kevin-smith/grdn"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.cbhq.net/kevin-smith/grdn"
  spec.metadata["changelog_uri"] = "https://github.cbhq.net/kevin-smith/grdn/blob/develop/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
