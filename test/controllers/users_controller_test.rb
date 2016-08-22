require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  setup do
    @room = rooms(:one)
    assert @room.save, 'room is saved'
    @user = users(:one)
    @params = { user: { name: @user.name, room_id: @room.id } }
  end

  test 'creates user' do
    assert_difference('User.count') do
      post users_url, params: @params
    end

    assert_equal User.last.room_id, @room.id
    assert not(User.last.moderator?), 'user is not moderator'
    assert_equal session[:user_id], User.last.id
    assert_redirected_to room_url(@room)
  end

  test 'renders error on creation of invalid user' do
    User.stub :new, @user do # @user does not belong to room, it is invalid
    assert_no_difference('User.count') do
      post users_url, params: @params
    end
    end

    assert_response :unprocessable_entity
    assert_equal response.body, '{"id":"unprocessable_entity","description":{"room":["must exist"]}}'
  end

  test 'renders error when created user cannot be saved' do
    @mock = Minitest::Mock.new
    @mock.expect :save, false
    @mock.expect :invalid?, false
    @mock.expect :errors, 'could not save user'
    User.stub :new, @mock do
    assert_no_difference('User.count') do
      post users_url, params: @params
    end
    end

    assert_response :internal_server_error
    assert_equal response.body, '{"id":"internal_server_error","description":"could not save user"}'
  end

  test 'updates user' do
    @user.room_id = @room.id
    assert @user.save, 'user is saved'
    @room_two = rooms(:two)
    assert @room_two.save, 'room two is saved'
    assert_not_equal @room.id, @room_two.id
    assert_equal @user.room_id, @room.id
    assert_equal @user.vote, nil
    params = {
      user: {
        name: 'Ek',
        vote: 5,
        room_id: @room_two.id
      }
    }
    assert_no_difference('User.count') do
      patch user_url(@user), params: params
    end
    @user.reload
    assert_equal @user.name, 'Ek'
    assert_equal @user.vote, 5
    assert_equal @user.room_id, @room_two.id
    assert_response :no_content
  end

  test 'destroys user' do
    assert_difference('User.count') do
      post users_url, params: @params
    end

    id = User.last.id
    assert session[:user_id], id

    assert_difference('User.count', -1) do
      delete user_url(id)
    end

    assert_equal session[:user_id], nil
    assert_not User.exists?(id)
    assert_redirected_to room_url(@room.id)
  end

end
