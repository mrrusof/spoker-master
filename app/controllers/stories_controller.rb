class StoriesController < ApplicationController

  before_action :set_story, only: [:destroy]

  # DELETE /stories/1
  def destroy # TODO authenticate request
    if not @story.destroy
      render json: { id: :internal_server_error, description: @story.errors }, status: :internal_server_error
    end
  end

  private

  def set_story
    @story = Story.find params[:id]
  end

end
