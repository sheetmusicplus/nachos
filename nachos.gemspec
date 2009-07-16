# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{nachos}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Smith"]
  s.date = %q{2009-07-16}
  s.description = %q{Nachos is a Ruby library for managing an encrypted data store.}
  s.email = %q{scott@ohlol.net}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.markdown"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README.markdown",
     "Rakefile",
     "VERSION",
     "conf/.empty",
     "lib/nachos.rb",
     "nachos.gemspec"
  ]
  s.homepage = %q{http://github.com/ohlol/nachos}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Nachos is a Ruby library for managing an encrypted data store.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
