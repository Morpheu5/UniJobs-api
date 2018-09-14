# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :authentication_tokens, dependent: :delete_all
  has_and_belongs_to_many :organizations
  has_many :contents

  validates :email,
            presence: true,
            uniqueness: true,
            allow_blank: false
end
