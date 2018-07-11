# frozen_string_literal: true

class Organization < ApplicationRecord
  belongs_to :organization, optional: true
  has_many :organizations
end
