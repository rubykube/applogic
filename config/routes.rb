# frozen_string_literal: true

Rails.application.routes.draw do
  # Frontend API routes.
  namespace :api do
    mount Frontend::Base, at: Frontend::Base.prefix
  end
end
