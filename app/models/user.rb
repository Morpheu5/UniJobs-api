# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :email,
            presence: true,
            confirmation: true,
            uniqueness: true,
            allow_blank: false

#   validates :email_confirmation,
#             presence: true,
#             allow_nil: false,
#             allow_blank: false
end
