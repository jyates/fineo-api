
module FineoApi
end

require 'optparse'
require 'ostruct'
require 'aws/aws_util'
require 'aws/s3_upload'
require 's3_deployer'
require 'deploy_api'

module Deploying
  def parse(args)
    options = OpenStruct.new
    options.s3 = "deploy.fineo.io/api"
    options.api = []

    OptionParser.new do |opts|
      opts.banner = "Usage: deploy [options]"
      opts.separator "Deploy the Fineo API"
      opts.separator "  Options:"

      opts.on("-i", "--input DIRECTORY", "Input directory for swagger files") do |dir|
        options.input = dir
      end

      opts.on("-o", "--output DIRECTORY", "Output directory for the configuration update files") do |dir|
        options.output = dir
      end

      opts.on("-a", "--api NAME", "Name of the api to deploy. REPEATABLE") do |name|
        options.api << name
      end

      opts.on("--s3 LOCATION", "S3 bucket + object to which we should deploy. Default: "+
        "#{options.s3}") do |s3|
        options.s3 = s3
      end

      opts.on("--test PROPERTIES", "API was created for testing. The S3 target will be provided " +
        "by the specified properties file") do |test|
        options.test = test
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
    end.parse!(args)
    options
  end

  def get_deployer(options)
    options.force ? \
      FineoApi::Deploy.new(options.creds) : \
      FineoApi::S3Deployer.new(options.creds, options)
  end
end
