require './lib/tzoffset/version'

Gem::Specification.new do |s|
  s.name     = 'tz_offset'
  s.version  = TZOffset::VERSION
  s.authors  = ['Victor Shepelev']
  s.email    = 'zverok.offline@gmail.com'
  s.homepage = 'https://github.com/molybdenum-99/tz_offset'

  s.summary = 'Simple and solid timezone offset class'
  s.description = <<-EOF
  EOF
  s.licenses = ['MIT']

  s.files = `git ls-files`.split($RS).reject do |file|
    file =~ /^(?:
    spec\/.*
    |Gemfile
    |Rakefile
    |\.rspec
    |\.gitignore
    |\.rubocop.yml
    |\.travis.yml
    )$/x
  end
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 2.1.0'

  s.add_development_dependency 'rubocop', '>= 0.40'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-its'
  s.add_development_dependency 'simplecov', '~> 0.9'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubygems-tasks'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'infoboxer'
  s.add_development_dependency 'timecop'
end
