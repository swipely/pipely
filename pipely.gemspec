$:.push File.expand_path("../lib", __FILE__)

require "pipely/version"

Gem::Specification.new do |s|
  s.name        = "pipely"
  s.version     = Pipely::VERSION
  s.authors     = ["Matt Gillooly"]
  s.email       = ["matt@swipely.com"]
  s.homepage    = "http://github.com/swipely/pipely"
  s.summary     = "Generate dependency graphs from pipeline definitions."
  s.license     = 'MIT'

  s.files = Dir["{lib}/**/*"] + ["Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "ruby-graphviz"
  s.add_dependency "rake"
  s.add_dependency "virtus", "~>1.0.0"
  s.add_dependency "fog", "~>1.19.0"
  s.add_dependency "unf"
  s.add_dependency "uuidtools"
  s.add_dependency "activesupport"
  s.add_development_dependency "rspec"
  s.add_development_dependency "cane"
  s.add_development_dependency "timecop"

  s.executables << 'pipely'
end
