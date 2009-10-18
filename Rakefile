# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/ministat.rb'

Hoe.new('ministat', MiniStat::VERSION) do |p|
  p.rubyforge_name = 'ministat'
  p.author = 'Dean Hudson'
  p.email = 'dean@ero.com'
  p.summary = 'A small and simple library to generate statistical info on single-variable datasets.'
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n") 
  p.remote_rdoc_dir = ''
end

# vim: syntax=Ruby
