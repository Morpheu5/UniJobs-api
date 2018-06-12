class Content < ApplicationRecord
    has_many :content_blocks, -> { order(order: :asc) }
end
