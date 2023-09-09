class StoryPresenter < SimpleDelegator
  def name
    ActionController::Base.helpers.sanitize __getobj__.name
  end
end
