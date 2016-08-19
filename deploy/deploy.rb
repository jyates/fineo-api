
# include lib/ dir
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

input = File.absolute_path(options.input)

deployer = Deploy.new(options.creds)
Dir["#{input}/*-swagger-integrations,authorizers.json"].each { |api|
  parts = File.basename(api).split "-"
  name = parts[0]
  next if name == "api" # skip the customer focused version
  id = Apis[name]
  deployer.deploy(name, api, id)
}
