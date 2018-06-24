# frozen_string_literal: true

class ContentBlock < ApplicationRecord
  belongs_to :content
  after_create :reload_uuid
end
