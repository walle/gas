require './spec/spec_helper'

require './lib/gas'

describe Gas::Users do

  before :each do
    @name = 'Fredrik Wallgren'
    @email = 'fredrik.wallgren@gmail.com'
    @nickname = 'walle'
    @dir = File.join(Dir.tmpdir, "gas_#{rand(42000000-100000) + 10000}")
    @file_path = File.join(@dir, 'gas_users')
    @users = Gas::Users.new @file_path
  end

  after :each do
    File.delete @file_path
    Dir.delete @dir
  end

  it 'should be able to parse users from users format' do
    users = "[#{@nickname}]\n  name = #{@name}\n  email = #{@email}\n\n[user2]\n  name = foo\n  email = bar"
    file = File.new(@file_path, "w")
    file.puts users
    file.close
    @users = Gas::Users.new @file_path
    @users.users.count.should be 2
    @users.users[0].name.should eq @name
    @users.users[0].email.should eq @email
    @users.users[0].nickname.should eq @nickname
  end

  it 'should be able to save the config' do
    @users.users.count.should be 0
    @users.add Gas::User.new('Foo Bar', 'foo@bar.com', 'foobar')
    @users.save!
    @users = Gas::Users.new @file_path
    @users.users.count.should be 1
  end
end