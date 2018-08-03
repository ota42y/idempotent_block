
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "idempotent_block/version"

Gem::Specification.new do |spec|
  spec.name          = "idempotent_block"
  spec.version       = IdempotentBlock::VERSION
  spec.authors       = ["ota42y"]
  spec.email         = ["ota42y@gmail.com"]

  spec.summary       = 'Execute passed transaction block by once using database unique key.'
  spec.description   = 'Execute passed transaction block by once using database unique key.'
  spec.homepage      = 'https://github.com/ota42y/idempotent_block'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activerecord'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "database_rewinder"
  spec.add_development_dependency "fincop"
end
