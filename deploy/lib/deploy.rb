
class Deploy
  def initialize(creds)
    @gateway = Aws::APIGateway::Client.new(region: 'us-east-1',
                                            credentials: creds,
                                            validate_params: true)
  end

  def deploy(name, api, id)
    return create(name, api) if id.nil?
    update(name, api, id)
  end

private

  def update(name, api, id)
    puts "Updating #{name} - #{id}"
    File.read(api, "r") do |file|
      @gateway.put_rest_api({
        rest_api_id: id
        mode: "overwrite",
        fail_on_warnings: false,
        body: file
      })
    end
  end

  def create(name, api)
    File.read(api, "r") do |file|
      @gateway.import_rest_api({
        fail_on_warnings: false,
        body: file
      })
    end
  end
end
