require './spec/spec_helper'

require './lib/gas'

describe Gas::Users do

  before :each do
    @name = 'Fredrik Wallgren'
    @email = 'fredrik.wallgren@gmail.com'
    @nickname = 'walle'
    users = "[#{@nickname}]\n  name = #{@name}\n  email = #{@email}\n\n[user2]\n  name = foo\n  email = bar"
    @file = Tempfile.new('gas_users')
    @file.write users
    @file.close
    @users = Gas::Users.new @file.path
  end

  after :each do
    @file.unlink
  end

  it 'should be able to parse users from users format' do
    @users.users.count.should be 2
    @users.users[0].name.should eq @name
    @users.users[0].email.should eq @email
    @users.users[0].nickname.should eq @nickname
  end
end