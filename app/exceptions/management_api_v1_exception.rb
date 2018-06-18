# frozen_string_literal: true

class ManagementAPIv1Exception < Faraday::ClientError
  attr_accessor :response
  def initialize(response)
    @response = response
    super response.body.fetch('error', 'External services error')
  end

  def status
    @response.status
  end
end
