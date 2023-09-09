class User < ApplicationRecord
  belongs_to :room

  validates :vote, estimate: true
end
