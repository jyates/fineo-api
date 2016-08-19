
require 'aws-sdk'
require 'yaml'

module AwsUtil

  def load_credentials(credentials_file)
    begin
      creds = YAML.load(File.read(credentials_file))
    rescue Exception => e
      puts "Could not read credentials file at: #{credentials_file}"
      raise e
    end
    creds
  end

  def gateway(credentials_file)
    creds = load_credentials(credentials_file)
    creds = Hash[creds.map{|k,v|
      [k.to_sym, v]
    }]
    creds[:region] = "us-east-1"
    creds[:validate_params] = true
    Aws::APIGateway::Client.new(creds)
  end
end
