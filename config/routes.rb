# frozen_string_literal: true

Rails.application.routes.draw do
  # Frontend API routes.
  mount FrontendAPI::Base, at: FrontendAPI::Base::PREFIX
end
