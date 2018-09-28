# frozen_string_literal: true

module Api
  class RootController < V1::ApplicationController
    def index
      render json: {
        api_version: Rails.configuration.api_version,
        api_environment: Rails.env
      }
    end
  end
end
  