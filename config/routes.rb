# frozen_string_literal: true

Rails.application.routes.draw do

  get 'users/whoami', to: 'users#whoami'
  post 'users/verify_email', to: 'users#verify_email'
  resources :users
  post 'login', to: 'users#login'
  post 'logout', to: 'users#logout'

  resources :contents do
    resources :content_blocks
  end
  get 'contents/slug/:slug', to: 'contents#find_by_slug'

  resources :organizations do
    member do
      get 'ancestors'
    end
  end
end
