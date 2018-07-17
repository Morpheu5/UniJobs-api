# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :users
  resources :contents do
    resources :content_blocks
  end
  resources :organizations
end
