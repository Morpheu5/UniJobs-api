# frozen_string_literal: true

class UserMailer < ApplicationMailer
    
    def verify_email
        body = """
        Welcome to UniJobs.it!

        Please go to the following URL to verify your e-mail address and fully activate your account.

        #{Rails.configuration.site_baseurl}/verify_email?token=#{params[:user].verification_token}

        Thanks for signing up!

        Your friends at UniJobs.it
        """
        mail(to: params[:user].email,
            body: body,
            content_type: "text/plain",
            subject: "UniJobs.it -- Please verify your e-mail address")
    end
  end