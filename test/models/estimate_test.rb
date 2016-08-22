require 'test_helper'

class EstimateTest < ActiveSupport::TestCase

  test '#to_s' do
    [1,2,3,5,8,13,20,40,100,110,120,nil].each do |n|
      if Estimate::ESTIMATES_TO_PRETTY.has_key? n
        assert_equal Estimate::ESTIMATES_TO_PRETTY[n], Estimate.pretty(n)
      else
        assert_equal n.to_s, Estimate.pretty(n)
      end
    end
  end

end
