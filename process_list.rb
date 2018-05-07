#!/usr/bin/env ruby
#
class Program
  def initialize(src, des, list_path)
    @src = src
    @des = des
    @list_path = list_path
  end

  def run!
    File.open(@list_path).each_line do |line|
      puts `./find_extract.rb "#{@src}" "#{@des}" "#{line}"`
    end
  end
end

program = Program.new ARGV[0], ARGV[1], ARGV[2]
program.run!

