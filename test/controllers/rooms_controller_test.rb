require 'test_helper'

class RoomsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @room = rooms(:one)
    @moderator = users(:one)
    @params = { room: { name: @room.name }, moderator: { name: @moderator.name } }
  end

  test 'creates room and moderator' do
    assert_difference('Room.count') do
    assert_difference('User.count') do
      post rooms_create_url, params: @params
    end
    end

    assert User.last.room_id == Room.last.id, 'user belongs to room'
    assert User.last.moderator?, 'user is moderator'
    assert session[:user_id] == User.last.id, 'user id is stored in session'
    assert_redirected_to room_url(Room.last)
  end

  test 'renders error on creation of invalid room' do
    @room.estimate = 6
    Room.stub :new, @room do
    assert_no_difference('Room.count') do
      post rooms_create_url, params: @params
    end
    end

    assert_response :unprocessable_entity
    assert_equal '{"id":"unprocessable_entity","description":{"estimate":["6 is not a valid estimate"]}}', response.body
  end

  def unsavable_mock entity
    @mock = Minitest::Mock.new
    @mock.expect :save, false
    @mock.expect :invalid?, false
    @mock.expect :errors, "could not save #{entity}"
    return @mock
  end

  test 'renders error when created room cannot be saved' do
    @mock = unsavable_mock 'room'
    @mock.expect :story_name=, RoomsController::DEFAULT_STORY_NAME, [String]
    Room.stub :new, @mock do
    assert_no_difference('Room.count') do
      post rooms_create_url, params: @params
    end
    end

    assert_response :internal_server_error
    assert_equal '{"id":"internal_server_error","description":"could not save room"}', response.body
  end

  test 'renders error on creation of invalid moderator' do
    @moderator.vote = 6
    User.stub :new, @moderator do
    assert_no_difference('User.count') do
      post rooms_create_url, params: @params
    end
    end

    assert_response :unprocessable_entity
    assert_equal '{"id":"unprocessable_entity","description":{"vote":["6 is not a valid estimate"]}}', response.body
  end

  test 'renders error when created moderator cannot be saved' do
    @mock = unsavable_mock 'moderator'
    @mock.expect :room_id=, nil, [Fixnum]
    @mock.expect :moderator=, nil, [true]
    User.stub :new, @mock do
    assert_no_difference('User.count') do
      post rooms_create_url, params: @params
    end
    end

    assert_response :internal_server_error
    assert_equal '{"id":"unprocessable_entity","description":"could not save moderator"}', response.body
  end

  test 'updates room' do
    assert @room.save, 'room is saved'
    assert_equal 'RoomOne', @room.name
    assert_equal nil, @room.story_name
    assert_equal nil, @room.estimate
    params = {
      room: {
        name: 'new name',
        story_name: 'US123',
        estimate: 5
      }
    }
    assert_no_difference('Room.count') do
      patch room_url(@room), params: params
    end
    @room.reload
    assert_equal 'new name', @room.name
    assert_equal 'US123', @room.story_name
    assert_equal 5, @room.estimate
    assert_response :no_content
  end

  test 'destroys room' do
    skip 'wip'
  end

  test 'shows votes' do
    assert_difference('User.count') do
      post rooms_create_url, params: @params
    end
    assert_equal User.last.id, session[:user_id]
    assert_equal true, User.last.moderator?
    assert_equal User.last.room_id, Room.last.id

    post "#{room_url(Room.last.id)}/show-votes"
    assert_response :no_content
    assert_equal '', response.body
  end

  test 'refuses to show votes when user is not moderator' do
    skip('figure out how to set session[:user_id]')
    assert_difference('User.count') do
      post rooms_create_url, params: @params
    end
    puts "test: User.last.id = #{User.last.id}"
    user = User.new(name: 'not moderator', room_id: Room.last.id)
    assert user.save, 'user is saved'
    session[:user_id] = user.id
    puts "test: session[:user_id] = #{session[:user_id]}"
    puts "test: user.id = #{user.id}"

    post "#{room_url(Room.last.id)}/show-votes"
    puts "test: session[:user_id] = #{session[:user_id]}"
    assert_response :unauthorized
  end

  test 'clears votes' do
    skip 'wip'
  end

  test 'refuses to clear votes when user is not moderator' do
    skip 'wip'
  end

  test 'closes voting' do
    skip 'wip'
  end

  test 'refuses to close voting when user is not moderator' do
    skip 'wip'
  end

  test 'sets story name' do
    skip 'wip'
  end

  test 'gives state' do
    skip 'wip'
  end

end
