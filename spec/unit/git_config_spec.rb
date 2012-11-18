require './spec/spec_helper'

require './lib/gas'

describe Gas::GitConfig do

  before :each do
    @name = 'Fredrik Wallgren'
    @email = 'fredrik.wallgren@gmail.com'
    @nickname = 'Fred'
  end

  it 'should be able to get current user from gitconfig' do
    mock_cli_call(Gas::GitConfig, 'git config --global --get user.name') { @name + "\n" }
    mock_cli_call(Gas::GitConfig, 'git config --global --get user.email') { @email + "\n" }

    user = Gas::GitConfig.current_user
    user.name.should eq @name
    user.email.should eq @email
  end

  it 'should return nil if no current user is present in gitconfig' do
    mock_cli_call(Gas::GitConfig, 'git config --global --get user.name') { nil }
    mock_cli_call(Gas::GitConfig, 'git config --global --get user.email') { nil }

    Gas::GitConfig.current_user.should be_nil
  end


  describe "Multiple users" do

    before :each do
      @user1 = Gas::User.new(@name, @email, @nickname)   # create a primary user for testing
    end

    it "should be able to set the current user" do
      # setup the cli interrupt things...
      mock_cli_call(Gas::GitConfig, "git config --global user.name \"#{@user1.name}\"") { nil }
      mock_cli_call(Gas::GitConfig, "git config --global user.email \"#{@user1.email}\"") { nil }
      mock_cli_call(Gas::GitConfig, 'git config --global --get user.name') { @user1.name + "\n" }
      mock_cli_call(Gas::GitConfig, 'git config --global --get user.email') { @user1.email + "\n" }

      Gas::GitConfig.change_user @user1

      user = Gas::GitConfig.current_user
      user.name.should eq @user1.name
      user.email.should eq @user1.email
    end

    it 'should be able to change the current user' do
      name = 'Test Testsson'
      email = 'test@testsson.com'
      nickname = 'test'

      # User 1 cli interrupt things...
      mock_cli_call(Gas::GitConfig, "git config --global user.name \"#{@name}\"") { nil }
      mock_cli_call(Gas::GitConfig, "git config --global user.email \"#{@email}\"") { nil }
      mock_cli_call(Gas::GitConfig, 'git config --global --get user.name') { @name + "\n" }
      mock_cli_call(Gas::GitConfig, 'git config --global --get user.email') { @email + "\n" }

      Gas::GitConfig.change_user @user1

      user = Gas::GitConfig.current_user
      user.name.should eq @name
      user.email.should eq @email      # test that the user switch worked (paranoid, huh?)

      # User 2 cli interrupt things...
      mock_cli_call(Gas::GitConfig, "git config --global user.name \"#{name}\"") { nil }
      mock_cli_call(Gas::GitConfig, "git config --global user.email \"#{email}\"") { nil }
      mock_cli_call(Gas::GitConfig, 'git config --global --get user.name') { name + "\n" }
      mock_cli_call(Gas::GitConfig, 'git config --global --get user.email') { email + "\n" }

      @user2 = Gas::User.new(name, email, nickname)   # create user 2
      Gas::GitConfig.change_user @user2

      user = Gas::GitConfig.current_user
      user.name.should eq name
      user.email.should eq email       # test that the user changed appropriately
    end

  end
end
