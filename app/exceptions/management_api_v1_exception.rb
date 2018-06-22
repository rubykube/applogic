# frozen_string_literal: true

class ManagementAPIv1Exception < Faraday::ClientError
  attr_accessor :status

  def initialize(response)
    super response.body.fetch('error', 'External services error'), response
    @status = response.status.in?(400...500) ? 422 : 503
  end
end
