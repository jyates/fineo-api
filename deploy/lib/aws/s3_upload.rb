
class FineoApi::S3Upload

  def initialize(creds, verbose)
    @s3 = Aws::S3::Resource.new(credentials: creds,
                                validate_params: true,
                                log_level: :debug)
    @verbose = verbose
  end

  def upload(source, bucket, key)
    source = File.absolute_path(source)
    s3_full_name = File.join("s3://", bucket, key)
    puts "   Uploading #{source} \n\t -> #{s3_full_name}...." if @verbose

    # fix the bucket name/prefix to match the s3 format
    parts = bucket.split "/"
    bucket = parts.shift
    key = File.join(parts, key) unless parts.empty?
    success = @s3.bucket(bucket).object(key).upload_file(source)
    # catch just in case there was a failure
    raise "Failed to upload #{source} to #{s3_full_name}!" unless success
    s3_full_name
  end
end
