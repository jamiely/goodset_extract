#!/usr/bin/env ruby

require 'tmpdir'

class Program
  def initialize(fn, destination, options = {})
    @goodset7z = fn
    @dest = destination
  end
  def extract_7z!
    cmd = "7z e -y -o\"#{@tmpdir}\" \"#{@goodset7z}\""
    STDERR.puts "Attempting command #{cmd}"
    `#{cmd}`
  end

  def list
    `ls #{@tmpdir}`.lines.map(&:strip)
  end

  def valid
    v = valid_us
    v = valid_europe if v.empty?
    v = valid_us_loose if v.empty?
    v = valid_europe_loose if v.empty?

    v
  end

  def valid_europe
    list.select do |line|
      line =~ /\(.*E.*\)/ &&
        line =~ /\[!\]/
    end
  end

  def valid_us
    list.select do |line|
      line =~ /\(.*U.*\)/ &&
        line =~ /\[!\]/
    end
  end

  def valid_us_loose
    list.select do |line|
      line =~ /\(.*U.*\)/
    end
  end

  def valid_europe_loose
    list.select do |line|
      line =~ /\(.*E.*\)/
    end
  end

  def extract!
    extract_7z!

  end

  def select_best
    v = valid
    puts "Found valid selections: #{v}"
    sorted = v.sort_by do |line|
      matches = line.match("PRG(\d+)")
      if !matches.nil? && matches.length > 1
        matches[1]
      else
        line.length
      end
    end
    sorted.first
  end

  def fix_name(name)
    newname = name
    prevname = name

    begin
      prevname = newname
      newname = newname.gsub(/ *\[.+\](.\w+)$/, '\\1')
      newname = newname.gsub(/ *\(.+\)(.\w+)$/, '\\1')
      newname.strip!
    end while newname != prevname

    newname
  end

  def should_zip?(file)
    %w|.nes .smc .gen|.any? do |ext|
      file.end_with? ext
    end
  end

  def repackage!(file)
    puts "Repackaging #{file}"
    new_unzipped_name = fix_name(file)
    new_zipped_name = File.basename(new_unzipped_name,'.*') + ".zip"

    FileUtils.copy "#{@tmpdir}/#{file}", "#{@tmpdir}/#{new_unzipped_name}"

    if should_zip? file
      cmd = %Q|cd "#{@tmpdir}" && zip "#{@dest}/#{new_zipped_name}" "#{new_unzipped_name}"|
      puts cmd
      puts `#{cmd}`
    else
      FileUtils.mv "#{@tmpdir}/#{new_unzipped_name}", "#{@dest}/#{new_unzipped_name}"
    end
  end

  def run!
    Dir.mktmpdir do |tmpdir|
      @tmpdir = tmpdir
      extract!
      best = select_best
      repackage!(best) unless best.nil?
    end
  end

end


program = Program.new ARGV[0], ARGV[1]
program.run!

