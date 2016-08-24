
require 'aws-sdk'
require 'yaml'

module FineoApi::AwsUtil

  def load_credentials(credentials_file)
    begin
      creds = YAML.load(File.read(credentials_file))
    rescue Exception => e
      puts "Could not read credentials file at: #{credentials_file}"
      raise e
    end
    creds
  end
end
