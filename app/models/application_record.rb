# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def reload_uuid
    return unless attributes.key? 'uuid'
    self[:uuid] = self.class.where(id: id).pluck(:uuid).first
  end
end
