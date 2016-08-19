
require 'aws-sdk'
require 'aws_util'

class Promote
  include AwsUtil
  def initialize(creds)
    @gateway = gateway(creds)
  end

  def promote(id, stage, description)
    ensure_stage(id, stage)
    deploy(id, stage, desc(description))
  end

private

  def ensure_stage(id, stage)
    info = {rest_api_id: id, stage_name: stage}
    begin
      @gateway.get_stage(info)
    rescue Aws::APIGateway::Errors::NotFoundException
      deployment = deploy(id, stage, desc("Initial stage creation"))
    end
  end

  def deploy(id, stage, desc)
    @gateway.create_deployment({
      rest_api_id: id,
      stage_name: stage,
      description: desc
    })
  end

  def desc(description)
    "#{description} - Automated deployment on #{Time.now}."
  end
end
