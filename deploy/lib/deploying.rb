
require 'optparse'
require 'ostruct'
require 'deploy'
require 'apis'
require 'aws/aws_util'
require 'aws/s3_upload'

module Deploying
  def parse(args)
    options = OpenStruct.new
    options.s3 = "deploy.fineo.io/api"

    OptionParser.new do |opts|
      opts.banner = "Usage: deploy [options]"
      opts.separator "Deploy the Fineo API"
      opts.separator "  Options:"

      opts.on("-i", "--input DIRECTORY", "Input directory for swagger files") do |dir|
        options.input = dir
      end

      opts.on("-o", "--output DIRECTORY", "Output directory for the cloudformation template "+
        "update files") do |dir|
        options.output = dir
      end

      opts.on("-a", "--api NAME", "Name of the api to deploy. By default, deploys all apis") do |name|
        options.api = name
      end

      opts.on("--s3 LOCATION", "S3 bucket + object to which we should deploy. Default: "+
        "#{options.s3}") do |s3|
        options.s3 = s3
      end

      opts.on("--credentials FILE", "Credentials file to use for upload") do |creds|
        options.creds = creds
      end

      opts.on("--really-force-api-deployment", "WARNING: Only used for unusual circumstances. "+
        "Forces the deployment of the api directly to AWS Api Gateway, rather than just pushing "+
        "updated schema file, generating a change set and waiting for a cloud template change.")
        do |force|
        puts "  --------  WARNING --------- "
        puts " This should only be used in extreme circumstances to force deployment of the api. "
        puts "Instead, you should just deploy the new API(s) to s3, commit the update to the " +
        "deployment repository and wait for a cloudformation template update."
        puts " *** You have bee warned *** "
        puts "  --------  WARNING --------- "
        options.force = true
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
      Deploy.new(options.creds) : \
      S3Deployer.new(options.creds, options)
  end
end

module FineoApi
end
