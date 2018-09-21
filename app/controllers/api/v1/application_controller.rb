# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ActionController::API
      include ActionController::HttpAuthentication::Token::ControllerMethods
      include Pundit

      before_action :set_locale
    
      rescue_from ::V1::Authenticatable::UnauthorizedException do |exception|
        head :unauthorized, 'WWW-Authenticate' => 'Bearer', 'X-Error' => exception.message || ''
      end

      def set_locale
        I18n.locale = params[:locale] || I18n.default_locale
      end  
    end
  end
end