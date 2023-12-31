name = File.basename(__FILE__, ".gemspec")
version = ["lib", "ext/lib"].find do |dir|
  break File.foreach(File.join(__dir__, dir, "#{name}.rb")) do |line|
    /^\s*VERSION\s*=\s*"(.*)"/ =~ line and break $1
  end rescue nil
end

Gem::Specification.new do |spec|
  spec.name          = name
  spec.version       = version
  spec.authors       = ["Tanaka Akira"]
  spec.email         = ["akr@fsij.org"]

  spec.summary       = %q{Representation of the name of a file or directory on the filesystem}
  spec.description   = %q{Representation of the name of a file or directory on the filesystem}
  spec.homepage      = "https://github.com/ruby/pathname"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")
  spec.licenses      = ["Ruby", "BSD-2-Clause"]

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = []
  spec.require_paths = ["lib"]
  spec.extensions    = %w[ext/pathname/extconf.rb]
end
