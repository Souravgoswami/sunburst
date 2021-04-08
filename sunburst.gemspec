require_relative 'lib/sunburst/version'

Gem::Specification.new do |s|
	s.name = "sunburst"
	s.version = Sunburst::VERSION
	s.authors = ["Sourav Goswami"]
	s.email   = %w(souravgoswami@protonmail.com)
	s.summary = %q(Run a process for a given time, kill it with SIGKILL, report CPU time and memory usage)
	s.description = s.summary
	s.homepage = "https://github.com/Souravgoswami/sunburst/"
	s.license = "MIT"
	s.required_ruby_version = Gem::Requirement.new(">= 2.6.0")
	s.files = Dir.glob(%w(exe/** lib/**/*.rb ext/**/*.{c,rb,h} bin/** LICENCE))
	s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
	s.extensions = Dir.glob("ext/**/extconf.rb")
	s.require_paths = ["lib"]
	s.extra_rdoc_files = Dir.glob(%w(README.md))
	s.bindir = "exe"
end
