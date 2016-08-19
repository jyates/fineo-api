#!/usr/bin/env ruby

File.expand_path(File.join(__dir__, "lib")).tap {|pwd|
  $LOAD_PATH.unshift(pwd) unless $LOAD_PATH.include?(pwd)
}

require 'optparse'
require 'ostruct'
require 'deploy'
require 'apis'

options = OpenStruct.new

OptionParser.new do |opts|
  opts.banner = "Usage: deploy.rb [options]"
  opts.separator "Deploy the Fineo API"
  opts.separator "  Options:"

  opts.on("-i", "--input DIRECTORY", "Input directory for swagger files") do |dir|
    options.input = dir
  end

  opts.on("-a", "--api NAME", "Name of the api to deploy. By default, deploys all apis") do |name|
    options.api = name
  end

  opts.on("--credentials FILE", "Credentials file to use for upload") do |creds|
    options.creds = creds
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options.verbose = true
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!(ARGV)

deployer = Deploy.new(options.creds)
input = File.absolute_path(options.input)

if options.api.nil?
  Dir["#{input}/*-swagger-integrations,authorizers.json"].each { |api|
    parts = File.basename(api).split "-"
    name = parts[0]
    next if name == "api" # skip the customer focused version
    id = Apis[name]
    deployer.deploy(name, api, id)
  }
else
  name = options.api
  id = Apis[name]
  deployer.deploy(options.api, "#{input}/#{name}-swagger-integrations,authorizers.json", id)
end
