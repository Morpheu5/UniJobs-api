# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include Pundit

  rescue_from Authenticatable::UnauthorizedException do |exception|
    head :unauthorized, 'WWW-Authenticate' => 'Bearer', 'X-Error' => exception.message || ''
  end
end
