require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "tickle"
    gem.summary = 'natural language parser for recurring events'
    gem.description = 'Tickle is a date/time helper gem to help parse natural language into a recurring pattern.  Tickle is designed to be a compliment of Chronic and can interpret things such as "every 2 days, every Sunday, Sundays, Weekly, etc.'
    gem.email = "jlippiner@noctivity.com"
    gem.homepage = "http://github.com/noctivityinc/tickle"
    gem.authors = ["Joshua Lippiner"]
    gem.add_dependency('chronic', '>= 0.2.3')
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "tickle #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
