require './spec/spec_helper'

require './lib/gas'

describe Gas::User do
  it 'should be able to parse name and email from gitconfig format' do
    name = 'Fredrik Wallgren'
    email = 'fredrik.wallgren@gmail.com'
    gitconfig = "[other stuff]\n  foo = bar\n\n[user]\n  name = #{name}\n  email = #{email}\n\n[foo]\n  bar = foo"
    user = Gas::User.parse gitconfig
    user.name.should == name
    user.email.should == email
  end

  it 'should output in the right format' do
    name = 'Fredrik Wallgren'
    email = 'fredrik.wallgren@gmail.com'
    nickname = 'walle'
    user = Gas::User.new name, email, nickname
    user.to_s.should == "[#{nickname}]\n  name = #{name}\n  email = #{email}"
  end

  it 'should output a git user in the right format' do
    name = 'Fredrik Wallgren'
    email = 'fredrik.wallgren@gmail.com'
    user = Gas::User.new name, email
    user.git_user.should == "[user]\n  name = #{name}\n  email = #{email}"
  end

  it 'should be able to have a nickname' do
    name = 'Fredrik Wallgren'
    email = 'fredrik.wallgren@gmail.com'
    nickname = 'walle'
    user = Gas::User.new name, email, nickname
    user.nickname.should == nickname
  end
end
