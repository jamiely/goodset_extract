#!/usr/bin/env ruby

require 'fuzzy_match'

class Program
  def initialize(source_dir, destination_dir, find_text)
    @srcdir = source_dir
    @desdir = destination_dir
    @findstr = find_text
  end
  def run!
    files = Dir.entries(@srcdir)
    #puts files
    fz = FuzzyMatch.new files
    results = fz.find(@findstr)

    if results.nil?
      puts "Could not find a result for #{find_text}"
    else
      puts `./extract.rb "#{@srcdir}/#{results}" "#{@desdir}"`
    end
  end
end

program = Program.new ARGV[0], ARGV[1], ARGV[2]
program.run!

