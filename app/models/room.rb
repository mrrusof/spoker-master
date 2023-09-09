class Room < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :stories, dependent: :destroy

  validates :estimate, estimate: true
end
