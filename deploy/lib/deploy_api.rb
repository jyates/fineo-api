
class FineoApi::DeployApi
  include FineoApi::AwsUtil
  def initialize(creds)
    @gateway = gateway(creds)
  end

  def deploy(name, api, id)
    return create(name, api) if id.nil?
    update(name, api, id)
  end

  def flush(); end

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
