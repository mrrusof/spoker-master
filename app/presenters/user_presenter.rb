class UserPresenter < SimpleDelegator
  def name
    ActionController::Base.helpers.sanitize __getobj__.name
  end

  def vote
    v = __getobj__.vote
    return Estimate.pretty v if room.visible_votes?

    v ? 'voted' : 'waiting'
  end

  def moderator
    __getobj__.moderator? ? 'M' : ''
  end
end
