# frozen_string_literal: true

require 'api_constraints'

Rails.application.routes.draw do
  apipie

  scope module: :api do
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

      get 'organizations/tree', to: 'organizations#free_text_tree'
      resources :organizations do
        member do
          get 'ancestors'
        end
      end

      get 'social_posts/cycle', to: 'social_posts#cycle'
      resources :social_posts
    end
  end
end
