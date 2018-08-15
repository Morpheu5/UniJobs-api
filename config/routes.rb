# frozen_string_literal: true

Rails.application.routes.draw do

  resources :users
  get 'users/whoami', to: 'users#whoami'
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
