Gem::Specification.new do |s|
  s.name     = 'shrimple'
  s.version  = '0.3.0'
  s.authors  = ['Scott Bronson']
  s.email    = ['brons_shrimple@rinspin.com']
  s.homepage = 'http://github.com/bronson/shrimple'
  s.summary  = 'A simple Ruby interface to PhantomJS'
  s.description = 'Use PhantomJS to generate PDFs, PNGs, etc from Files, URLs, ...'

  s.require_paths = ['lib']
  s.files = Dir['README.markdown', 'lib/**/*', 'Gemfile', 'Rakefile']
  s.test_files = Dir['spec/**/*']

  s.add_development_dependency 'rspec', ['>= 2.5']
  s.license = 'MIT'
end
