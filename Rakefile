require 'rubygems'
require 'rspec/core/rake_task'


RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "renum"
    s.summary = "provides a readable but terse enum facility for Ruby"
    s.email = "duelin.markers@gmail.com"
    s.homepage = "http://github.com/duelinmarkers/renum"
    s.description = "This library provides a readable but terse enum facility for Ruby."
    s.authors = ["John Hume"]
    s.add_development_dependency 'rspec', '~>2.6'
    s.add_development_dependency 'jeweler', '~>1.6'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler or a dependency not available. To install: sudo gem install jeweler"
end
