require './spec/spec_helper'

require './lib/gas'

describe Gas::Gitconfig do

  before :each do
    @name = 'Fredrik Wallgren'
    @email = 'fredrik.wallgren@gmail.com'
    gitconfig = "[other stuff]\n  foo = bar\n\n[user]\n  name = #{@name}\n  email = #{@email}\n\n[foo]\n  bar = foo"
    @gitconfig = Gas::Gitconfig.new gitconfig
  end

  it 'should be able to get current user from gitconfig' do
    user = @gitconfig.current_user
    user.name.should == @name
    user.email.should == @email
  end

  it 'should be able to change the current user' do
    name = 'Test Testsson'
    email = 'test@testsson.com'
    @gitconfig.change_user name, email

    user = @gitconfig.current_user
    user.name.should == name
    user.email.should == email
  end
end
