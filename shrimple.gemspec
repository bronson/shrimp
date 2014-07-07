Gem::Specification.new do |s|
  s.name     = 'shrimple'
  s.version  = '0.8.2'
  s.authors  = ['Scott Bronson']
  s.email    = ['brons_shrimple@rinspin.com']
  s.homepage = 'http://github.com/bronson/shrimple'
  s.summary  = 'A simple Ruby interface to PhantomJS'
  s.description = 'Use PhantomJS to generate PDFs, PNGs, text files, etc.'
  s.license = 'MIT'

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_runtime_dependency 'hashie'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'dimensions'
end
