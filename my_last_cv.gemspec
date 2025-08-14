require_relative "lib/my_last_cv/version"

Gem::Specification.new do |spec|
  spec.name          = "my-last-cv"
  spec.version       = MyLastCV::VERSION rescue "0.0.1"
  spec.authors       = ["Maxime Hanicotte"]
  spec.email         = ["max_hanicotte@msn.com"]

  spec.summary       = "Generate your CV from Markdown to PDF"
  spec.description   = "MyLastCV turns a Markdown CV into a styled PDF using Prawn. "\
                       "Configurable styles (fonts, sizes, margins, accent color) and "\
                       "project-level custom fonts support."

  spec.homepage      = "https://www.maxime.hanicotte.net/my-last-cv/"
  spec.licenses       = ["GPL-3.0-or-later"]
  spec.required_ruby_version = ">= 3.0"

  spec.files         = Dir.glob("lib/**/*.rb") + ["exe/my_last_cv", "README.md"]
  spec.bindir        = "exe"
  spec.executables   = ["my_last_cv"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "prawn", "~> 2.5"

  spec.add_development_dependency "rake", "~> 13.3"
  spec.add_development_dependency "rspec", "~> 3.13"

  spec.metadata = {
    "homepage_uri"            => spec.homepage,
    "source_code_uri"         => "https://github.com/maxime-hanicotte/my-last-cv",
    "changelog_uri"           => "https://github.com/maxime-hanicotte/my_last_cv/blob/main/CHANGELOG.md",
    "bug_tracker_uri"         => "https://github.com/maxime-hanicotte/my_last_cv/issues",
    "documentation_uri"       => "https://github.com/maxime-hanicotte/my_last_cv#readme",

    # Recommanded for RubyGems.org
    "rubygems_mfa_required"   => "true"
  }
end
