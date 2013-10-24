require 'test_helper'

class UserFriendshipTest < ActiveSupport::TestCase
	should belong_to(:user)
	should belong_to(:friend)

	test "that creating a friendship works without raising an exception" do 
	  	assert_nothing_raised do
	  		UserFriendship.create user: users(:robert), friend: users(:william)
	  	end
  	end

  	test "that creating a friendship based on user id and friend id works" do
    	UserFriendship.create user_id: users(:robert).id, friend_id: users(:william).id
    	assert users(:robert).pending_friends.include?(users(:william))
  	end

  	context "a new instance" do
  		setup do
  			@user_friendship = UserFriendship.new user: users(:robert), friend: users(:kelly)
  		end

  		should "have a pending state" do
  			assert_equal 'pending', @user_friendship.state
  		end
  	end

  	context "#send_request_email" do
  		setup do
  			@user_friendship = UserFriendship.create user: users(:robert), friend: users(:kelly)
  		end

  		should "send an email" do
  			assert_difference 'ActionMailer::Base.deliveries.size', 1 do
  				@user_friendship.send_request_email
  			end
  		end
  	end

  context "#mutual_friendship" do
    setup do
      UserFriendship.request users(:robert), users(:kelly)
      @friendship1 = users(:robert).user_friendships.where(friend_id: users(:kelly).id).first
      @friendship2 = users(:kelly).user_friendships.where(friend_id: users(:robert).id).first

    end

    should "correctly find the mutual friendship" do
      assert_equal @friendship2, @friendship1.mutual_friendship
      
    end
  end

  context "#accept_mutual_friendship!" do
    setup do
      UserFriendship.request users(:robert), users(:kelly)
    end

    should "accept the mutual friendship" do
      friendship1 = users(:robert).user_friendships.where(friend_id: users(:kelly).id).first
      friendship2 = users(:kelly).user_friendships.where(friend_id: users(:robert).id).first


      friendship1.accept_mutual_friendship!
      friendship2.reload
      assert_equal 'accepted', friendship2.state
    end
  end

  context "#accept" do
    setup do
      @user_friendship = UserFriendship.request users(:robert), users(:kelly)
    end

    should "set the state to accepted" do
      @user_friendship.accept!
      assert_equal "accepted", @user_friendship.state
    end

    should "send an acceptance email" do
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        @user_friendship.accept!
      end
    end

    should "include the friend in the list of friends" do
      @user_friendship.accept!
      users(:robert).friends.reload
      assert users(:robert).friends.include?(users(:kelly))
    end

    should "accept the mutual friendship" do
      @user_friendship.accept!
      assert_equal 'accepted', @user_friendship.mutual_friendship.state
    end
  end
  
  context ".request" do
    should "create two user frienships" do
      assert_difference 'UserFriendship.count', 2 do
        UserFriendship.request(users(:robert), users(:kelly))
      end
    end

    should "send a friend request email" do
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        UserFriendship.request(users(:robert), users(:kelly))
      end
    end
  end
end
