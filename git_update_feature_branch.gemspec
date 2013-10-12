# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git_update_feature_branch/version'

Gem::Specification.new do |spec|
  spec.name          = "git_update_feature_branch"
  spec.version       = GitUpdateFeatureBranch::VERSION
  spec.authors       = ["Andreas Gnyp"]
  spec.email         = ["agnyp@friendscout24.de"]
  spec.description   = %q{This gem will update your feature branch with master as well as with the work of your colleagues. You can work on the same branch. Updating will use rebasing, so your history will always be nice and clean.}
  spec.summary       = %q{Updates a feature-branch with master and collaborators using rebasing.}
  spec.homepage      = "https://github.com/agnyp/git-update-feature-branch"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
