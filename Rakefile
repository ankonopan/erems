# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "erems"
  gem.homepage = "http://github.com/josetonyp/erems"
  gem.license = "MIT"
  gem.summary = %Q{TODO: one-line summary of your gem}
  gem.description = %Q{TODO: longer description of your gem}
  gem.email = "josetonyp@latizana.com"
  gem.authors = ["Jose Antonio Pio Gil"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['test'].execute
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "erems #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require_relative "lib/erems.rb"

namespace :packages do

  desc "Search for packages and update version"
  task :scrap_list do
    e = Erems.new
    e.scrap_for_packages_text
  end

  desc "Download Packages and update fields"
  task :download do
    e = Erems.new
    e.dowload_packages
  end

  desc "Show package info"
  task :show do
    if ENV["name"]
      ap RPackage.where(name: ENV["name"]).first.to_h
    end
  end

  desc "Show packages batch info"
  task :list do
    if ENV["size"]
      ap RPackage.not.where(name: nil).limit(ENV["size"].to_i).all.map &:to_h
    end
  end

end
