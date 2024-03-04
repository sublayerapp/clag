require_relative "lib/clag/version"

Gem::Specification.new do |spec|
  spec.name        = 'clag'
  spec.version     = Clag::VERSION
  spec.authors     = ['Scott Werner']
  spec.email       = ['scott@sublayer.com']
  spec.homepage    = 'https://github.com/sublayerapp/clag'
  spec.summary     = 'Generate command line commands in your terminal using an LLM'
  spec.description = 'Clag is a command line tool that generates command line commands right in your terminal and puts it into your clipboard for you to paste into your terminal.'
  spec.license     = 'MIT'

  spec.files       = `git ls-files`.split("\n")
  spec.bindir      = 'exe'
  spec.executables << 'clag'
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3'

  spec.add_dependency 'cli-kit', '~> 5'
  spec.add_dependency 'cli-ui', '~> 2.2.3'
  spec.add_dependency 'ruby-openai', '~> 6'
  spec.add_dependency 'httparty', '~> 0.21'
  spec.add_dependency 'clipboard', '~> 1.3'
  spec.add_dependency 'activesupport'
  spec.add_dependency "pry"
  spec.add_dependency "nokogiri"

  spec.add_development_dependency 'rake', '~> 10.0'
end
