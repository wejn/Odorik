#!/usr/bin/env ruby

# Simple script to help with resources/??.lproj/Localizable.strings
# de-duplication (as in -- sometimes I have the same key more than
# once, which is a no-no).
#
# Author: Michal Jirku <box at wejn dot org>

if ARGV.size.zero?
	STDERR.puts "Usage: #{File.basename($0)} <file>"
	exit 1
end

for filename in ARGV
	STDERR.puts "Processing: #{filename} ..."
	defs = Hash.new(0)
	File.open(filename).each do |ln|
		ln.strip!
		next if ln =~ /^(\/\/|\/\*|$)/
		ln = ln.sub(/"\s+=\s+".*/, "\"")
		defs[ln] += 1
	end
	out = false
	for k, v in defs
		next if v == 1
		out = true
		puts k
	end

	unless out
		STDERR.puts "You are god among men (no duplicates in this lproj)."
	end
end
exit 0
