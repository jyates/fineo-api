
require 'json'

# Does an api deployment to s3
class FineoApi::S3Deployer
  include FineoApi::AwsUtil

  def initialize(creds, options)
    credentials = load_credentials(creds)
    @s3 = FineoApi::S3Upload.new(credentials, options.verbose)
    if options.test
      @props = JSON.parse(File.read(options.test))["api"]
      @test = true
    else
      @test = false
      @now = Time.now
      @bucket = options.s3
    end
    @output = options.output
    @updates = []
    @verbose = options.verbose
  end

  def deploy(name, api)
     base = File.basename(api)
    if @test
      config = @props[name]
      bucket = config["s3"]["bucket"]
      key = config["s3"]["key"]
    else
      parts = @bucket.split "/"
      bucket = parts.shift
      key = File.join(parts, name, @now.to_s, base)
    end
    s3 = @s3.upload(api, bucket, key)

    add_api(name, s3)
  end

  def flush()
    updates = {}
    FileUtils.mkdir_p @output
    file = File.join(@output, "updates.json")
    @updates.each{|update|
      # Each api gets its own parent, which in thrun updates the stack by name... kinda weird, but that's how we layed out configuration
      name =  update["name"]
      change = update["api"]
      out = {"api" => {name =>change}}
      updates[name] = out
    }

    puts "Writing updates to: #{file}" if @verbose
    File.open(file, "w") do |f|
      f.write(JSON.pretty_generate(updates))
    end
  end

private

  def add_api(name, file)
    file = file.sub("s3://", "")
    parts = file.split "/"
    bucket = parts.shift
    key = File.join(parts)
    name.gsub!("_", "-") # handle the schema-internal/schema_internal dichotomy
    update = {"name" => name, "api" =>{
      "s3" =>{
        "bucket" => bucket,
        "key" => key
      }
    }}
    @updates << update
  end

end
