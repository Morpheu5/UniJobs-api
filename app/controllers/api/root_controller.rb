# frozen_string_literal: true

module Api
  class RootController < V1::ApplicationController
    def index
      render json: {
        version: ENV['API_VERSION'] || Rails.env
      }
    end
  end
end
  