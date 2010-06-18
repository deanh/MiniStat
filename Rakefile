require 'rake/gempackagetask'
require './lib/ministat.rb'

spec = Gem::Specification.new do |p|
  p.version = MiniStat::VERSION
  p.name = 'ministat'
  p.author = 'Dean Hudson'
  p.email = 'dean@ero.com'
  p.summary = 'A small and simple library to generate statistical info on single-variable datasets.'
  p.description = File.read(File.join(File.dirname(__FILE__), 'README'))
  p.requirements = ['An eye for data and a strong will to live']
  p.has_rdoc = true
  p.files = Dir['**/**']
end
Rake::GemPackageTask.new(spec).define
