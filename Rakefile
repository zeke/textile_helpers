require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'


desc 'Default: run rspecs.'
task :default => :spec
 
desc 'Test the textile_helpers plugin.'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.libs << 'lib'
  t.verbose = true
end

desc 'Generate documentation for the textile_helpers plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'TextileHelpers'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


 
