# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def reload_uuid
    if self.attributes.has_key? 'uuid'
      self[:uuid] = self.class.where(id: id).pluck(:uuid).first
    end
  end
end
