# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    mount Frontend::Base, at: Frontend::Base.prefix
  end
end
