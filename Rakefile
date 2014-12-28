# ripped off of jamis buck's lovely net::sftp rakefile

require 'rubygems'
require 'rubygems/gem_runner'
require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'rake/contrib/sshpublisher'
require './lib/choice/version'

PACKAGE_NAME = "choice"
PACKAGE_VERSION = Choice::Version::STRING

SOURCE_FILES = FileList.new do |fl|
  [ "examples", "lib", "test" ].each do |dir|
    fl.include "#{dir}/**/*"
  end
  fl.include "Rakefile"
end

PACKAGE_FILES = FileList.new do |fl|
  fl.include "CHANGELOG", "README.rdoc", "LICENSE"
  fl.include SOURCE_FILES
end

def can_require( file )
  begin
    require file
    return true
  rescue LoadError
    return false
  end
end

desc "Default task"
task :default => [ :test ]

desc "Build documentation"
task :doc => [ :rdoc ]

task :rdoc => SOURCE_FILES

Rake::TestTask.new :test do |t|
  t.test_files = [ "test/test*" ]
end

desc "Clean generated files"
task :clean do
  rm_rf "pkg"
  rm_rf "api"
end

desc "Prepackage warnings and reminders"
task :prepackage do
  unless ENV["OK"] == "yes"
    puts "========================================================="
    puts " Please check that the following files have been updated"
    puts " in preparation for release #{Choice::Version::STRING}:"
    puts
    puts "   README.rdoc (with latest info)"
    puts "   CHANGELOG (with the recent changes)"
    puts "   lib/choice/version.rb (with current version number)"
    puts
    puts " Did you remember to 'rake tag'?"
    puts
    puts " If you are sure these have all been taken care of, re-run"
    puts " rake with 'OK=yes'."
    puts "========================================================="
    puts

    abort
  end
end

desc "Tag the current trunk with the current release version"
task :tag do
  tag = "v#{Choice::Version::STRING}"
  warn "WARNING: this will tag using the tag #{tag} and push the ref to git://www.github.com/defunkt/choice"
  warn "If you do not wish to continue, you have 5 seconds to cancel by pressing CTRL-C..."
  5.times { |i| print "#{5-i} "; $stdout.flush; sleep 1 }
  system "git tag -a #{tag} -m \"Tagging the #{tag} release\""
  system "git push origin #{tag}"
end

package_name = "#{PACKAGE_NAME}-#{PACKAGE_VERSION}"
package_dir = "pkg"
package_dir_path = "#{package_dir}/#{package_name}"

gz_file = "#{package_name}.tar.gz"
gem_file = "#{package_name}.gem"

task :gzip => SOURCE_FILES + [ "#{package_dir}/#{gz_file}" ]
task :gem  => SOURCE_FILES + [ "#{package_dir}/#{gem_file}" ]

desc "Build all packages"
task :package => [ :prepackage, :test, :gzip, :gem ]

directory package_dir

file package_dir_path do
  mkdir_p package_dir_path rescue nil
  PACKAGE_FILES.each do |fn|
    f = File.join( package_dir_path, fn )
    if File.directory?( fn )
      mkdir_p f unless File.exist?( f )
    else
      dir = File.dirname( f )
      mkdir_p dir unless File.exist?( dir )
      rm_f f
      safe_ln fn, f
    end
  end
end

file "#{package_dir}/#{gz_file}" => package_dir_path do
  rm_f "#{package_dir}/#{gz_file}"
  chdir package_dir do
    sh %{tar czvf #{gz_file} #{package_name}}
  end
end

file "#{package_dir}/#{gem_file}" => package_dir do
  spec = Gem::Specification.new do |s|
  	s.name = 'choice'
  	s.version = Choice::Version::STRING
  	s.platform = Gem::Platform::RUBY
  	s.date = Time.now
  	s.summary = "Choice is a command line option parser."
  	s.description = "Choice is a simple little gem for easily defining and parsing command line options with a friendly DSL."
  	s.require_paths = [ 'lib' ]
  	s.files = %w[README.rdoc CHANGELOG LICENSE]
  	[ 'lib/**/*', 'test/*', 'examples/*' ].each do |dir|
  	  s.files += Dir.glob( dir ).delete_if { |item| item =~ /^\./ }
  	end
  	s.author = "Chris Wanstrath"
  	s.email = 'chris@ozmm.org'
  	s.homepage = 'http://www.github.com/defunkt/choice'
  	s.autorequire = 'choice'
  end
  Gem::Builder.new(spec).build
  mv gem_file, "#{package_dir}/#{gem_file}"
end

rdoc_dir = "api"

desc "Build the RDoc API documentation"
task :rdoc => :rdoc_core do
  img_dir = File.join( rdoc_dir, "files", "doc", "images" )
  mkdir_p img_dir
  Dir["doc/images/*"].reject { |i| File.directory?(i) }.each { |f|
    cp f, img_dir
  }
end

RDoc::Task.new(:rdoc_core) do |rdoc|
  rdoc.rdoc_dir = rdoc_dir
  rdoc.title    = "Choice -- A simple command line option parser"
  rdoc.options << '--line-numbers --inline-source --main README.rdoc'
  rdoc.rdoc_files.include 'README.rdoc'
  rdoc.rdoc_files.include 'lib/**/*.rb'
end
