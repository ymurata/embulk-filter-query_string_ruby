
Gem::Specification.new do |spec|
  spec.name          = "embulk-filter-query_string_ruby"
  spec.version       = "0.1.10"
  spec.authors       = ["Yuma Murata"]
  spec.summary       = "Query String Ruby filter plugin for Embulk"
  spec.description   = "Query String Ruby"
  spec.email         = ["murata@ebisol.co.jp"]
  spec.licenses      = ["MIT"]
  spec.homepage      = "https://github.com/ymurata/embulk-filter-query_string_ruby"

  spec.files         = `git ls-files`.split("\n") + Dir["classpath/*.jar"]
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  spec.add_dependency  'addressable'
  spec.add_development_dependency 'embulk', ['>= 0.8.14']
  spec.add_development_dependency 'bundler', ['>= 1.10.6']
  spec.add_development_dependency 'rake', ['>= 10.0']
end
