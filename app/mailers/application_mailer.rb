# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'UniJobs.it (noreply) <noreply@unijobs.it>'
  layout 'mailer'
end
