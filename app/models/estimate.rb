class Estimate

  USER_ESTIMATES = [1,2,3,5,8,13,21,34,55,89,110,120]
  VALID_ESTIMATES = [1,2,3,5,8,13,21,34,55,89,110,120,nil]
  ESTIMATES_TO_PRETTY = { 110 => '?', 120 => 'coffee', nil => '' }

  class << self

    def estimates_for_cards
      USER_ESTIMATES.map { |e| [e, pretty(e)] }
    end

    def pretty(estimate)
      if ESTIMATES_TO_PRETTY.has_key? estimate
        ESTIMATES_TO_PRETTY[estimate]
      else
        estimate.to_s
      end
    end

    def has_pretty?(estimate)
      estimate != nil and ESTIMATES_TO_PRETTY.has_key? estimate.to_i
    end

  end

end
