Gem::Specification.new do |spec|
  spec.name          = "my-last-cv"
  spec.version       = MyLastCV::VERSION rescue "0.0.1"
  spec.licenses       = ["GPL-3.0-or-later"]
  spec.authors       = ["Maxime Hanicotte"]
  spec.email         = ["max_hanicotte@msn.com"]
  spec.homepage      = "https://www.maxime.hanicotte.net/my-last-cv/"
  spec.summary       = "Generate your CV from Mardown to PDF"
  spec.files         = Dir.glob("lib/**/*.rb") + ["exe/my_last_cv", "README.md"]
  spec.bindir        = "exe"
  spec.executables   = ["my_last_cv"]
  spec.require_paths = ["lib"]
  spec.add_dependency "prawn", "~> 2.5"
  spec.required_ruby_version = ">= 3.0"
end
