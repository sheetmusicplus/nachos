# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{nachos}
  s.version = "0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Smith"]
  s.date = %q{2009-07-13}
  s.description = %q{Nachos is a Ruby library for managing an encrypted data store.}
  s.email = %q{scott@ohlol.net}
  s.files = ["LICENSE", "README.markdown", "conf", "lib", "lib/nachos.rb"]
  s.has_rdoc = false
  s.homepage = %q{http://github.com/ohlol/nachos"}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{nachos}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Nachos is a Ruby library for managing an encrypted data store.}

#  if s.respond_to? :specification_version then
#    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
#    s.specification_version = 2
#
#    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
#      s.add_runtime_dependency(%q<mime-types>, [">= 1.15"])
#      s.add_runtime_dependency(%q<diff-lcs>, [">= 1.1.2"])
#    else
#      s.add_dependency(%q<mime-types>, [">= 1.15"])
#      s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
#    end
#  else
#    s.add_dependency(%q<mime-types>, [">= 1.15"])
#    s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
#  end
end
