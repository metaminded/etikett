$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "etikett/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "etikett"
  s.version     = Etikett::VERSION
  s.authors     = ["Florian Thomas"]
  s.email       = ["ft@metaminded.com"]
  s.homepage    = "https://github.com/metaminded"
  s.summary     = "Tag your objects"
  s.description = "Tag, search and organize your objects."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"

  s.add_development_dependency "pg"
end
