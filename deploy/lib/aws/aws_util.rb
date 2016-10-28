
require 'aws-sdk'
require 'yaml'

module FineoApi::AwsUtil

  def self.load_credentials_from_env
    return Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
  end

  def load_credentials(credentials_file)
    begin
      creds = YAML.load(File.read(credentials_file))
      return Aws::Credentials.new(creds['access_key_id'], creds['secret_access_key'])
    rescue Exception => e
      puts "Could not read credentials file at: #{credentials_file}" unless credentials_file.nil?
      return FineoApi::AwsUtil.load_credentials_from_env
    end
  end
end
