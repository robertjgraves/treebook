require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should have_many(:user_friendships) 
  should have_many(:friends)

  test "a user should enter a first name" do 
  	user = User.new
  	assert !user.save
  	assert !user.errors[:first_name].empty?
  end

  test "a user should enter a last name" do 
  	user = User.new
  	assert !user.save
  	assert !user.errors[:last_name].empty?
  end

  test "a user should enter a profile name" do 
  	user = User.new
  	assert !user.save
  	assert !user.errors[:profile_name].empty?
  end

  test "a user should have a unique profile name" do
  	user = User.new
  	user.first_name = "Robert"
  	user.last_name = "Graves"
  	user.profile_name = "robertjgraves"
  	user.email = "robertjgraves@gmail.com"
  	user.password = 'password!'
  	user.password_confirmation = 'password!'
  	assert !user.save
  	assert !user.errors[:profile_name].empty?
  end

  test "a user should have a profile name without spaces" do
  	user = User.new
  	user.profile_name ="My Profile With Spaces"

  	assert !user.save
  	assert !user.errors[:profile_name].empty?
  	assert user.errors[:profile_name].include?("must be formatted correctly. No spaces!")
  end

  test "a user can have a correctly formatted profile name" do
    user = User.new(first_name: 'Robert', last_name: 'Graves', email: 'robertjgraves@outlook.com', profile_name: 'rgraves')
    user.password = user.password_confirmation = 'asdfasdf'

    assert user.valid?
  end

  test "that no error is raised when trying to access a friend list" do
    assert_nothing_raised do
      users(:robert).friends
    end
  end

  test "that creating friendships on a user works" do
    users(:robert).friends << users(:william)
    users(:robert).friends.reload
    assert users(:robert).friends.include?(users(:william))
  end

  test "that calling to_param on a user returns the profile_name" do
    assert_equal "robertjgraves", users(:robert).to_param
  end
end