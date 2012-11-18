require './spec/spec_helper'

require './lib/gas'

describe Gas::User do
  it 'should output in the right format' do
    name = 'Fredrik Wallgren'
    email = 'fredrik.wallgren@gmail.com'
    nickname = 'walle'
    user = Gas::User.new name, email, nickname
    user.to_s.should == "      [#{nickname}]\n         name = #{name}\n         email = #{email}"
  end

  it 'should output a git user in the right format' do
    name = 'Fredrik Wallgren'
    email = 'fredrik.wallgren@gmail.com'
    user = Gas::User.new name, email
    user.git_user.should == "      [user]\n         name = #{name}\n         email = #{email}"
  end

  it 'should be able to have a nickname' do
    name = 'Fredrik Wallgren'
    email = 'fredrik.wallgren@gmail.com'
    nickname = 'walle'
    user = Gas::User.new name, email, nickname
    user.nickname.should == nickname
  end

  it 'should be equal if all fields are equal' do
    user1 = Gas::User.new 'foo', 'bar', 'foobar'
    user2 = Gas::User.new 'foo', 'bar', 'foobar'
    user1.should == user2
  end

  it 'should be equal even with one user missing nickname' do
    user1 = Gas::User.new 'foo', 'bar', 'foobar'
    user2 = Gas::User.new 'foo', 'bar', ''
    user1.should == user2
  end

  it 'should not be equal if nicknames are set but mismatch' do
    user1 = Gas::User.new 'foo', 'bar', 'foobar'
    user2 = Gas::User.new 'foo', 'bar', 'baz'
    user1.should_not == user2
  end
end
