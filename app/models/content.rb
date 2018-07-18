# frozen_string_literal: true

class Content < ApplicationRecord
  has_many :content_blocks, -> { order(order: :asc) }
  belongs_to :organization
  after_create :reload_uuid
end
