# frozen_string_literal: true

module V1
  class Base < Grape::API
    version 'v1', using: :path

    mount V1::Withdraw
  end
end
