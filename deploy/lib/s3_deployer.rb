
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
  end

  def deploy(name, api, id)
     base = File.basename(api)
    if @test
      config = @props[name]
      bucket = config["s3"]["bucket"]
      key = config["s3"]["key"]
    else
      parts = @bucket.split "/"
      bucket = parts.shift
      key = File.join(parts, @now.to_s, name, base)
    end
    s3 = @s3.upload(api, bucket, key)

    add_api(name, s3)
  end

  def flush()
    @updates.each{|update|
      name =  update["name"]
      change = update["api"]
      FileUtils.mkdir_p @output
      file = File.join(@output, "#{name}-update.json")

      out = {"api" => {name =>change}}

      File.open(file, "w") do |f|
        f.write(JSON.pretty_generate(out))
      end
    }
  end

private

  def add_api(name, file)
    file = file.sub("s3://", "")
    parts = file.split "/"
    bucket = parts.shift
    key = File.join(parts)
    update = {"name" => name, "api" =>{
      "s3" =>{
        "bucket" => bucket,
        "key" => key
      }
    }}
    @updates << update
  end

end
