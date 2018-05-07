#!/usr/bin/env ruby

require 'fuzzy_match'

class Program
  def initialize(source_dir, destination_dir, find_text)
    @srcdir = source_dir
    @desdir = destination_dir
    @findstr = find_text.strip
  end

  # For normal matches, we test whether the file starts with the
  # passed name. If it does, we want to prioritize files with
  # the shortest length, since we assume these are the closest match.
  def find_normal_matches(files)
    files.select do |f|
      f.start_with? @findstr
    end.sort_by do |f|
      f.length
    end
  end

  def find_fuzzy_matches(files)
    #puts files
    fz = FuzzyMatch.new files
    results = fz.find(@findstr)
    if results
      [results]
    else
      []
    end
  end

  def find_matches
    files = Dir.entries(@srcdir)
    matches = find_normal_matches(files)
    puts "Found normal matches for #{@findstr}: #{matches}"

    if matches.nil? || matches.empty?
      fuzzy = find_fuzzy_matches(files)
      puts "Found fuzzy matches: #{fuzzy}"
      fuzzy
    else
      matches
    end
  end

  def run!
    results = find_matches

    puts "Found results for #{@findstr}: #{results}"

    results = results.first

    if results.nil?
      puts "Could not find a result for #{@findstr}"
    else
      puts `./extract.rb "#{@srcdir}/#{results}" "#{@desdir}"`
    end
  end
end

program = Program.new ARGV[0], ARGV[1], ARGV[2]
program.run!

