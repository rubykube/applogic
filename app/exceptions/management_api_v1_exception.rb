# frozen_string_literal: true

class ManagementAPIv1Exception < Faraday::ClientError
  def initialize(response)
    super response.body.fetch('error', 'External services error'), response
  end

  def status
    response.status.in?(400...500) ? 422 : 503
  end
end
