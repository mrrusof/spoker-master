class RoomPresenter < SimpleDelegator
  def name
    ActionController::Base.helpers.sanitize __getobj__.name
  end

  def story_name
    ActionController::Base.helpers.sanitize __getobj__.story_name
  end

  def estimate
    Estimate.pretty __getobj__.estimate
  end
end
