class RoomsController < ApplicationController
  DEFAULT_STORY_NAME = 'New Story (click to change)'
  LONG_POLLING_TIMEOUT_SECS = (ENV['POLL_TIMEOUT'] || 45).to_f
  LONG_POLLING_SLEEP_SECS = (ENV['POLL_SLEEP'] || 0.5).to_f

  # TODO set_* tighten if not already tight
  before_action :set_room, except: [:new, :create_w_moderator]
  before_action :set_user, only: [:show, :show_votes, :clear_votes, :close_voting]

  # GET /
  def new
  end

  # GET /rooms/1
  def show
  end

  # POST /rooms/create
  def create_w_moderator
    @room = RoomPresenter.new(Room.new(room_params))
    @room.story_name = DEFAULT_STORY_NAME # TODO move to config file # TODO test
    if @room.save
      @user = User.new(moderator_params)
      @user.room_id = @room.id
      @user.moderator = true
      if @user.save
        session[:user_id] = @user.id
        redirect_to room_url(@room)
      elsif @user.invalid?
        render json: { id: :unprocessable_entity, description: @user.errors }, status: :unprocessable_entity # TODO render error view
      else
        render json: { id: :unprocessable_entity, description: @user.errors }, status: :internal_server_error # TODO render error view
      end
    elsif @room.invalid?
      render json: { id: :unprocessable_entity, description: @room.errors }, status: :unprocessable_entity # TODO render error view
    else
      render json: { id: :internal_server_error, description: @room.errors }, status: :internal_server_error # TODO render error view
    end
  end

  # PATCH /rooms/1
  def update
    if @room.update(room_params)
      head :no_content
    else # TODO case split on HTTP 422 vs 500
      render json: { id: :unprocessable_entity, description: @room.errors }, status: :unprocessable_entity # TODO render error view
    end
  end

  # DELETE /rooms/1
  def destroy
    @room.destroy
    session.delete :user_id
    redirect_to root_url
  end

  # POST /rooms/1/show-votes
  def show_votes
    if not(@user) or not(@user.moderator?) or @room != @user.room # TODO factorize
      render json: { id: :unauthorized, description: 'you are not a moderator' }, status: :unauthorized
      return
    end
    @room.visible_votes = true
    @room.estimate = @room.users.map{|u| u.vote }.keep_if{|v| v != nil }.max
    if @room.save
      head :no_content
    else
      render json: { id: :internal_server_error, description: @user.errors }, status: :internal_server_error
    end
  end

  # POST /rooms/1/clear-votes
  def clear_votes
    if not(@user) or not(@user.moderator?) or @room != @user.room # TODO factorize
      render json: { id: :unauthorized, description: 'you are not a moderator' }, status: :unauthorized
      return
    end
    if not @room.visible_votes? # TODO factorize
      head :no_content
      return
    end
    clear_user_votes
    @room.visible_votes = false
    if not @room.save
      render json: { id: :internal_server_error, description: @user.errors }, status: :internal_server_error
    end
  end

  # POST /rooms/1/close-voting
  def close_voting # TODO have a transaction for this
    if not @user or not @user.moderator? or @room != @user.room # TODO factorize
      render json: { id: :unauthorized, description: 'you are not a moderator' }, status: :unauthorized
      return
    end
    if not @room.visible_votes? # TODO factorize
      head :no_content
      return
    end
    story = Story.new(name: @room.story_name,
                      estimate: @room.estimate,
                      room_id: @room.id)
    if not story.save
      render json: { id: :internal_server_error, description: story.errors }, status: :internal_server_error
      return
    end
    clear_user_votes
    @room.story_name = DEFAULT_STORY_NAME
    @room.visible_votes = false
    @room.estimate = nil
    if not @room.save
      render json: { id: :internal_server_error, description: @room.errors }, status: :internal_server_error
    end
  end

  # GET /rooms/1/state
  def state
    long_polling do
      { 'story-name': story_name,
        estimate: estimate,
        'estimated-stories': estimated_stories,
        votes: votes }
    end
  end

  private

  def set_room
    @room = RoomPresenter.new Room.find params[:id]
  end

  def set_user
    begin
      @user = User.find session[:user_id]
    rescue
      @user = nil
    end
  end

  def room_params
    params.require(:room).permit(:name, :story_name, :estimate)
  end

  def moderator_params
    params.require(:moderator).permit(:name)
  end

  def clear_user_votes
    @room.users.each do |u|
      u.vote = nil
      if not u.save
        render json: { id: :internal_server_error, description: u.errors }, status: :internal_server_error
      end
    end
  end

  def estimate
    @room.visible_votes? ? @room.estimate : 'waiting'
  end

  def story_name
    @room.story_name
  end

  def estimated_stories
    @room.stories.map { |s| StoryPresenter.new s }.map do |s|
      { uri: story_url(s), name: s.name, estimate: s.estimate }
    end
  end

  def votes
    @room.users.order(:name).map { |u| UserPresenter.new u }.map do |u|
      { name: u.name, vote: u.vote, moderator: u.moderator }
    end
  end

  def long_polling
    stop = Time.now + LONG_POLLING_TIMEOUT_SECS
    while true
      j = yield
      response.etag = j
      if Time.now >= stop or not request.etag_matches? response.etag
        break
      end
      sleep LONG_POLLING_SLEEP_SECS
      @room.reload
    end
    if request.etag_matches? response.etag
      head :not_modified
    else
      render json: j
    end
  end

end
