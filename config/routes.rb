# frozen_string_literal: true

require 'api_constraints'

Rails.application.routes.draw do

  apipie

  namespace :api do
    root 'root#index'

    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      get 'users/whoami', to: 'users#whoami'
      post 'users/verify_email', to: 'users#verify_email'
      resources :users
      post 'login', to: 'users#login'
      post 'logout', to: 'users#logout'

      post 'job_reporting', to: 'application#job_reporting'

      resources :contents do
        resources :content_blocks
      end
      get 'contents/slug/:slug', to: 'contents#find_by_slug'

      resources :organizations do
        # get 'organizations', to: 'organizations#free_text'
        get 'organizations/tree', to: 'organizations#free_text_tree'
        member do
          get 'ancestors'
        end
      end
    end
  end

end