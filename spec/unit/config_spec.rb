require './spec/spec_helper'

require './lib/gas'

describe Gas::Config do

  before :each do
    @name = 'Fredrik Wallgren'
    @email = 'fredrik.wallgren@gmail.com'
    @nickname = 'walle'
    config = "[#{@nickname}]\n  name = #{@name}\n  email = #{@email}\n\n[user2]\n  name = foo\n  email = bar"
    @config = Gas::Config.new nil, config
  end

  it 'should be able to parse users from config format' do
    @config.users.count.should be 2
    @config.users[0].name.should eq @name
    @config.users[0].email.should eq @email
    @config.users[0].nickname.should eq @nickname
  end

  it 'should output the users in the correct format' do
    user1 = Gas::User.new 'Fredrik Wallgren', 'fredrik.wallgren@gmail.com', 'walle'
    user2 = Gas::User.new 'foo', 'bar', 'user2'
    users = [user1, user2]
    config = Gas::Config.new users

    stub(config).is_current_user { false }

    config.to_s.should == "      [walle]\n         name = Fredrik Wallgren\n         email = fredrik.wallgren@gmail.com\n      [user2]\n         name = foo\n         email = bar"
  end

  it 'should be able to tell if a nickname exists' do
    user1 = Gas::User.new 'Fredrik Wallgren', 'fredrik.wallgren@gmail.com', 'walle'
    user2 = Gas::User.new 'foo', 'bar', 'user2'
    users = [user1, user2]
    config = Gas::Config.new users
    config.exists?('walle').should be_true
    config.exists?('foo').should be_false
    config.exists?('user2').should be_true
  end

  it 'should be able to get a user from a nickname' do
    user1 = Gas::User.new 'Fredrik Wallgren', 'fredrik.wallgren@gmail.com', 'walle'
    user2 = Gas::User.new 'foo', 'bar', 'user2'
    users = [user1, user2]
    config = Gas::Config.new users
    config.get('walle').should eq user1
    config.get('user2').should eq user2
    config['walle'].should eq user1
    config['user2'].should eq user2
    config[:walle].should eq user1
    config[:user2].should eq user2
  end

  it 'should be able to add users' do
    user1 = Gas::User.new 'Fredrik Wallgren', 'fredrik.wallgren@gmail.com', 'walle'
    user2 = Gas::User.new 'foo', 'bar', 'user2'
    users = [user1]
    config = Gas::Config.new users
    config.users.count.should be 1
    config.add user2
    config.users.count.should be 2
  end

  it 'should be able to delete users by nickname' do
    user1 = Gas::User.new 'Fredrik Wallgren', 'fredrik.wallgren@gmail.com', 'walle'
    user2 = Gas::User.new 'foo', 'bar', 'user2'
    users = [user1, user2]
    config = Gas::Config.new users
    config.users.count.should be 2
    config.delete 'walle'
    config.users.count.should be 1
    config.delete 'user2'
    config.users.count.should be 0
  end

  it 'should remove the ssh keys from .gas appropriately'

  it 'should remove the keys from .ssh if present'

end

