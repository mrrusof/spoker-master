class Story < ApplicationRecord
  belongs_to :room

  validates :estimate, estimate: true
end
