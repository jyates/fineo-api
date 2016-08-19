#!/usr/bin/env ruby

File.expand_path(File.join(__dir__, "lib")).tap {|pwd|
  $LOAD_PATH.unshift(pwd) unless $LOAD_PATH.include?(pwd)
}

require 'optparse'
require 'ostruct'
require 'deploy'
require 'apis'
require 'promote'

options = OpenStruct.new

OptionParser.new do |opts|
  opts.banner = "Usage: deploy.rb [options]"
  opts.separator "Deploy the Fineo API"
  opts.separator "  Options:"

  opts.on("-a", "--api NAME", "Name of api. Valid names are: #{Apis.keys}") do |name|
    options.api = name
  end

  opts.on("-s", "--stage STAGE", "Stage to which the API should be promoted") do |stage|
    options.stage = stage
  end

  opts.on("-d", "--desc DESCRIPTION", "Description of the deployment") do |desc|
    options.desc = desc
  end

  opts.on("--credentials FILE", "Credentials file to use for upload") do |creds|
    options.creds = creds
  end

  opts.on("-v", "--[no-]verbose", "Enable/Disable verbosity") do |v|
    options.verbose = true
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!(ARGV)

id = Apis[options.api]
Promote.new(options.creds).promote(id, options.stage, options.desc)
