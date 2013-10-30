#! /usr/bin/ruby

# MiniVM - Copyright (c) 2012,2013 David H. Hovemeyer
# Free software - see LICENSE.txt for license terms

# General-purpose front-end:
# - assemble assembly code to produce an executable
# - assemble assembly code and execute it
# - load an executable and execute it

require './Assembler.rb'
require './VirtualMachine.rb'
require './BinaryFile.rb'
require './ExeFile.rb'
require './Executor.rb'
require 'optparse'

mode = :execute
outfile = nil
interactive = false
optparse = OptionParser.new do |opts|
	opts.banner =  "Usage: MiniVM.rb [options] <filename>"

	opts.on('-a', '--assemble', 'translate assembly code to executable') do
		mode = :assemble
	end
	opts.on('-x', '--execute', 'execute assembly program or executable') do
		mode = :execute
	end
	opts.on('-o', '--output <name>', String, 'specify output file name') do |name|
		outfile = name
	end
	opts.on('-i', '--interactive', 'interactive execution') do
		interactive = true
	end
end

optparse.parse!
if ARGV.length != 1
	puts optparse
	exit 1
end
filename = ARGV[0]

puts "mode=#{mode}, filename=#{filename}"

m = /^(.*)(\.[^\.]+)$/.match(filename)
raise "Source file must have a file extension" if !m
base = m[1]
ext = m[2]

# Assemble or load the executable
exe = nil
case ext
when '.mvm'
	# Assembler file: assemble it to produce an ExeFile
	File.open(filename) do |f|
		a = Assembler.new(f)
		a.assemble()
		f.close()
		exe = a.get_exe()
	end
when '.mve'
	# Executable: load it to produce an ExeFile
	raise "Nothing to do" unless mode == :execute
	exe = ExeFile.read(filename)
else
	raise "Unknown file extension #{ext}"
end

if mode == :execute
	# Execute the executable
	x = Executor.new(exe)
	x.interactive = interactive
	x.execute()
else
	# Write executable to file
	if outfile.nil?
		outfile = "#{base}.mve"
	end

	outf = File.open(outfile, 'w')
	outf.extend(BinaryFile)
	ExeFile.write(outf, exe)
	outf.close()
end

# vim:ts=4: