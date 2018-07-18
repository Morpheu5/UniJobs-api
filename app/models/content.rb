# frozen_string_literal: true

class Content < ApplicationRecord
  has_many :content_blocks, -> { order(order: :asc) }, inverse_of: :content
  belongs_to :organization, inverse_of: :content
  after_create :reload_uuid
end
