lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'version'

Gem::Specification.new do |spec|

  spec.name          = "safedb"
  spec.version       = SafeDb::VERSION
  spec.authors       = [ "Apollo Akora" ]
  spec.email         = [ "devopsassets@gmail.com" ]

  spec.summary       = %q{safe locks and unlocks secrets in a simple, secure and intuitive way.}
  spec.description   = %q{safe is a credentials manager for the linux command line written in Ruby. It locks and unlocks secrets in a safe simple and intuitive manner. You can then visit websites, manufacture keys and passwords, inject credentials into Jenkins, and interact with many tools including S3, GoogleDrive, Terraform, Git and Docker.}
  spec.homepage      = "https://www.safedb.net"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.metadata["yard.run"] = "yri"
  spec.bindir        = "bin"
  spec.executables   = [ 'safe', 'safedb' ]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.5.0'

  spec.add_dependency 'inifile', '~> 3.0'
  spec.add_dependency 'thor', '~> 0.2'
  spec.add_dependency 'bcrypt'

  spec.add_development_dependency "bundler", "~> 1.16"

end
