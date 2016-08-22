require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def r
    @r ||= User.create
  end

  test 'validates valid :vote' do
    Estimate::VALID_ESTIMATES.each do |e|
      r.vote = e
      r.valid?
      assert r.errors[:vote].empty?
    end
  end

  test 'validates invalid :vote' do
    [4,6,7,9,10,11,12,14,15,16,17,18,19].each do |e|
      r.vote = e
      r.valid?
      assert r.errors[:vote].any?
    end
  end

  test 'gives pretty vote' do
    skip 'wip'
  end

end
