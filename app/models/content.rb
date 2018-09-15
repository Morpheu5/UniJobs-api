# frozen_string_literal: true

class Content < ApplicationRecord
  has_many :content_blocks, -> { order(order: :asc) }, inverse_of: :content, dependent: :destroy
  belongs_to :organization, inverse_of: :organizations
  belongs_to :user
  after_create :reload_uuid

  accepts_nested_attributes_for :content_blocks
end
