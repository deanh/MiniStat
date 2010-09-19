#!/usr/bin/env ruby -ws

require 'ministat'

if $f and File.exists($f)
  lines = []
  lines = File.readlines($f).each {|l| l.chomp!}
  puts MiniStat::Data.new(lines).to_s
else
  puts "Usage: ministat -f datafile"
end