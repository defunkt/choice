require 'rake/testtask'

task :default => [:tests]

Rake::TestTask.new :tests do |t|
  t.test_files = FileList['test/test*.rb']
end
