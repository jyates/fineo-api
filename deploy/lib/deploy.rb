
require 'aws-sdk'

class Deploy
  def initialize(creds)
    creds = Hash[creds.map{|k,v|
      [k.to_sym, v]
    }]
    creds[:region] = "us-east-1"
    creds[:validate_params] = true
    @gateway = Aws::APIGateway::Client.new(creds)
  end

  def deploy(name, api, id)
    return create(name, api) if id.nil?
    update(name, api, id)
  end

private

  def update(name, api, id)
    puts "Updating #{name} - #{id}"
    content = File.read(api)
    @gateway.put_rest_api({
      rest_api_id: id,
      mode: "overwrite",
      fail_on_warnings: false,
      body: content
    })
  end

  def create(name, api)
    file = File.read(api)
    @gateway.import_rest_api({
      fail_on_warnings: false,
      body: file
    })
  end
end
