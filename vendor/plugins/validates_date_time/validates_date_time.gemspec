# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{validates_date_time}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jonathan Viney", "Nick Stenning"]
  s.date = %q{2010-04-07}
  s.description = %q{A Rails plugin that adds an ActiveRecord validation helper to do range and start/end date checking in.}
  s.email = ["jonathan.viney@gmail.com", "nick@whiteink.com"]
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "CHANGELOG",
     "MIT-LICENSE",
     "README.markdown",
     "Rakefile",
     "VERSION",
     "init.rb",
     "lib/multiparameter_attributes.rb",
     "lib/parser.rb",
     "lib/validates_date_time.rb",
     "test/abstract_unit.rb",
     "test/database.yml",
     "test/date_test.rb",
     "test/date_time_test.rb",
     "test/fixtures/en.yml",
     "test/fixtures/people.yml",
     "test/fixtures/person.rb",
     "test/schema.rb",
     "test/time_test.rb",
     "validates_date_time.gemspec"
  ]
  s.homepage = %q{http://github.com/nickstenning/validates_date_time}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{A Rails plugin adds the ability to validate dates and times with ActiveRecord.}
  s.test_files = [
    "test/abstract_unit.rb",
     "test/date_test.rb",
     "test/date_time_test.rb",
     "test/fixtures/person.rb",
     "test/schema.rb",
     "test/time_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

