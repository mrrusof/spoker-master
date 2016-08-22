class User < ApplicationRecord
  belongs_to :room

  validates :vote, estimate: true

  def pretty_vote
    Estimate.pretty self[:vote]
  end
end
