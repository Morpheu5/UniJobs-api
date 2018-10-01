# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'UniJobs.it (noreply) <noreply@unijobs.it>'
  layout 'mailer'

  def job_reporting
    @job_url = params[:job_url]
    mail  to: 'info@unijobs.it',
          subject: 'UniJobs :: Job Reporter',
          body: """
            A user reported a job with the following URL.
            
            #{@job_url}
            
            IP: #{params[:ip]}
            RH: #{params[:rh]}
            UA: #{params[:ua]}
            CK: #{params[:ck]}

            Have fun!
            """
  end
end
