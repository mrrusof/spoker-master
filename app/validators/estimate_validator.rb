class EstimateValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    unless Estimate::VALID_ESTIMATES.include? value
      record.errors.add attribute, "#{value} is not a valid estimate"
    end
  end

end
