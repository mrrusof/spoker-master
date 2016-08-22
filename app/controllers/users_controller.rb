class UsersController < ApplicationController
  before_action :set_user, only: [:update, :destroy]

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to room_url(@user.room_id)
    elsif @user.invalid?
      render json: { id: :unprocessable_entity, description: @user.errors }, status: :unprocessable_entity # TODO render error view
    else
      render json: { id: :internal_server_error, description: @user.errors }, status: :internal_server_error # TODO render error view
    end
  end

  # PATCH /rooms/1
  def update # TODO authenticate request
    if @user.update user_params
      head :no_content
    else # TODO case split on HTTP 422 vs 500
      render json: { id: :unprocessable_entity, description: @user.errors }, status: :unprocessable_entity # TODO render error view
    end
  end

  # DELETE /users/:id
  def destroy # TODO call this from login button # TODO authenticate request
    @user.destroy
    session.delete :user_id
    redirect_to room_url(@user.room_id)
  end

  private

  def set_user
    @user = User.find params[:id]
  end

  def user_params
    params.require(:user).permit(:name, :vote, :room_id)
  end

end
