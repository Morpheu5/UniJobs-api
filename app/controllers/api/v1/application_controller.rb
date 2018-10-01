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

      def job_reporting
        job_report = params.require(:data).permit(:url)
        r = /^https?:\/\/.+$/
        if r.match(job_report[:url]).nil?
          render json: { error: 'Not a valid HTTP URL.' }, status: :bad_request
          return
        end

        ApplicationMailer.with(
          job_url: job_report[:url],
          ip: request.env['REMOTE_ADDR'],
          rh: request.env['REMOTE_HOST'],
          ua: request.env['HTTP_USER_AGENT'],
          ck: request.env['HTTP_COOKIE']
        ).job_reporting.deliver_now
        head :ok
      end
    end
  end
end
