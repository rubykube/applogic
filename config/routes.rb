# frozen_string_literal: true

Rails.application.routes.draw do
  mount BaseAPI, at: BaseAPI::PREFIX
end
