require 'test_helper'

class RoomTest < ActiveSupport::TestCase

  def r
    @r ||= Room.create
  end

  test 'validates valid :estimate' do
    Estimate::VALID_ESTIMATES.each do |e|
      r.estimate = e
      r.valid?
      assert r.errors[:estimate].empty?
    end
  end

  test 'validates invalid :estimate' do
    [4,6,7,9,10,11,12,14,15,16,17,18,19].each do |e|
      r.estimate = e
      r.invalid?
      assert r.errors[:estimate].any?
    end
  end

  test 'gives pretty estimate' do
    skip 'wip'
  end

end
