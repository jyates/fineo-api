#!/usr/bin/env ruby

# include the "lib" directory
File.expand_path(File.join(__dir__, "lib")).tap {|pwd|
  $LOAD_PATH.unshift(pwd) unless $LOAD_PATH.include?(pwd)
}

require 'liquid'
require 'ostruct'
require 'templater'
require 'json'
require 'optparse'

current = File.dirname(__FILE__)
options = {
  :output => File.join(current, ".."),
  :input =>  File.join(current, "input"),
}

OptionParser.new do |opts|
  opts.banner = "Usage: template.rb [options]"
  opts.separator "Liquid based templating for the Fineo API"
  opts.separator "  Options:"

  opts.on("-o", "--output DIRECTORY", "Output directory. Default: #{options[:output]}") do |v|
    options[:output] = v
  end

  opts.on("-i", "--input DIRECTORY", "Input directory. Default: #{options[:input]}") do |v|
    options[:input] = v
  end

  opts.on("-r", "--overrides OVERRIDE_JSON", "Template field overrides json file") do |v|
    options[:overrides] = v
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!(ARGV)

root = File.join(options[:input], "root.json")
default_file = File.join(options[:input], "defaults.json")
assigns = JSON.parse(File.read(default_file))
assigns.merge!(JSON.parse(File.read(options[:overrides]))) unless options[:overrides].nil?

# just the streaming
output = File.join(options[:output], "stream")
templater = Templater.new(output, "swagger-integrations,authorizers.json",
  options[:input], ["stream"])
templater.template(root, assigns.dup())

# just the batch

output = File.join(options[:output], "batch")
templater = Templater.new(output, "swagger-integrations,authorizers.json",
  options[:input], ["batch"])
templater.template(root, assigns.dup())

# combined, for the documentation
output = File.join(options[:output], "api")
templater = Templater.new(output, "swagger.json", options[:input], ["stream", "batch"])
templater.template(root, assigns.dup())
