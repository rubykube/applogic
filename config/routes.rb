# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    mount BaseAPI, at: BaseAPI.prefix
  end
end
