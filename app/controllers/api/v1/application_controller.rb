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

      rescue_from Pundit::NotAuthorizedError do |exception|
        head :forbidden, 'WWW-Authenticate' => 'Bearer', 'X-Error' => exception.message || ''
      end

      def set_locale
        I18n.locale = params[:locale] || I18n.default_locale
      end

      api :POST, '/job_reporting', 'Report a URL with a job offer'
      param :data, Hash, required: true do
        param :url, String, 'A well formed URL of the job offer', required: true
      end
      error :bad_request, 'If an invalid URL is provided'
      def job_reporting
        job_report = params.require(:data).permit(:url)
        r = /^https?:\/\/.+$/i
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
