require './spec/spec_helper'

require './lib/gas'
#require './lib/gas/user'

describe Gas::Gitconfig do

  before :each do
    @name = 'Fredrik Wallgren'
    @email = 'fredrik.wallgren@gmail.com'
    @nickname = 'Fred'
    @gitconfig = Gas::Gitconfig.new
  end

  it 'should be able to get current user from gitconfig' do
    mock_cli_call(@gitconfig, 'git config --global --get user.name') { @name + "\n" }
    mock_cli_call(@gitconfig, 'git config --global --get user.email') { @email + "\n" }

    user = @gitconfig.current_user
    user.name.should == @name
    user.email.should == @email
  end

  it 'should return nil if no current user is present in gitconfig' do
    mock_cli_call(@gitconfig, 'git config --global --get user.name') { nil }
    mock_cli_call(@gitconfig, 'git config --global --get user.email') { nil }

    @gitconfig.current_user.should == nil
  end
  

  describe "Multiple users" do
    
    before :each do
      @user1 = Gas::User.new(@name, @email, @nickname)   # create a primary user for testing
    end
    
    it "should be able to set the current user" do
      # setup the cli interrupt things...
      mock_cli_call(@gitconfig, "git config --global user.name \"#{@user1.name}\"") { nil }
      mock_cli_call(@gitconfig, "git config --global user.email \"#{@user1.email}\"") { nil }
      mock_cli_call(@gitconfig, 'git config --global --get user.name') { @user1.name + "\n" }
      mock_cli_call(@gitconfig, 'git config --global --get user.email') { @user1.email + "\n" }
      
      @gitconfig.change_user @user1
      
      user = @gitconfig.current_user
      user.name.should == @user1.name
      user.email.should == @user1.email
      user.nickname.should == @user1.nickname
    end
    
    it 'should be able to change the current user' do
      name = 'Test Testsson'
      email = 'test@testsson.com'
      nickname = 'test'
      
      # User 1 cli interrupt things...
      mock_cli_call(@gitconfig, "git config --global user.name \"#{@name}\"") { nil }
      mock_cli_call(@gitconfig, "git config --global user.email \"#{@email}\"") { nil }
      mock_cli_call(@gitconfig, 'git config --global --get user.name') { @name + "\n" }
      mock_cli_call(@gitconfig, 'git config --global --get user.email') { @email + "\n" }
      
      @gitconfig.change_user @user1
      
      user = @gitconfig.current_user
      user.name.should == @name
      user.email.should == @email      # test that the user switch worked (paranoid, huh?)
      
      # User 2 cli interrupt things...
      mock_cli_call(@gitconfig, "git config --global user.name \"#{name}\"") { nil }
      mock_cli_call(@gitconfig, "git config --global user.email \"#{email}\"") { nil }
      mock_cli_call(@gitconfig, 'git config --global --get user.name') { name + "\n" }
      mock_cli_call(@gitconfig, 'git config --global --get user.email') { email + "\n" }
      
      @user2 = Gas::User.new(name, email, nickname)   # create user 2
      @gitconfig.change_user @user2
      
      user = @gitconfig.current_user
      user.name.should == name
      user.email.should == email       # test that the user changed appropriately
    end
    
  end
end
