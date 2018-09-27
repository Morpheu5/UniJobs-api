# frozen_string_literal: true

class UserMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.verify_email.subject
  #
  def verify_email
    @user = params[:user]
    @verification_url = "#{Rails.configuration.site_baseurl}/verify_email?token=#{params[:user].verification_token}"
    mail(to: @user.email)
  end
end
