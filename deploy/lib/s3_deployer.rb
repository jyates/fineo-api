
require 'json'

# Does an api deployment to s3
class S3Deployer
  include FineoApi::AwsUtil

  def initialize(creds, options)
    credentials = load_creds(creds)
    @s3 = S3Upload.new(credentials, options.verbose)
    @now = Time.now
    @bucket = options.s3
    @output = options.output
    @updates = []
  end

  def deploy(name, api, id)
    parts = @bucket.split "/"
    bucket = parts.shift
    base = File.basename(api)
    key = File.join(parts, now, name, base)
    s3 = @s3.upload(api, bucket, key)
    add_api(name, s3)
  end

  def flush()
    @updates.each{|update|
      name =  update["name"]
      change = update["api"]
      file = File.join(@output, "#{name}-update.json")
      File.open(file, "w") do |f|
        f.write(JSON.pretty_generate(JSON.parse(change.to_json().to_s())))
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
