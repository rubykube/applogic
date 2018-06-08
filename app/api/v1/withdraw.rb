# frozen_string_literal: true

module V1
  class Withdraw < Grape::API
    desc 'List your withdraws as paginated collection.', scopes: %w[ history ]
    params do
    end

    get '/withdraws' do
    end
  end
end
