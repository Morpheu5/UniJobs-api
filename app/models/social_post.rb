class SocialPost < ApplicationRecord
  belongs_to :content

  attribute :status, :jsonb, default: { twitter: :NEW, facebook: :NEW }
  attribute :message, :string, default: ''
end
