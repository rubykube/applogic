# frozen_string_literal: true

class Peatio::ManagementAPIv1Client < ManagementAPIv1Client
  def initialize(*)
    super ENV.fetch('PEATIO_ROOT_URL'), Rails.configuration.x.peatio_management_api_v1_configuration
  end

  def create_withdraw(parameters = {})
    request(:post, '/withdraws/new', parameters, action: :write_withdraws)
  end
end
