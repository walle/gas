require './spec/spec_helper'

require './lib/gas'

describe Gas do

  before :each do

  end

  it 'should show correct version' do
    output = capture_stdout { Gas.print_version }
    output.should == "#{Gas::VERSION}\n"
  end

  it 'should show correct usage' do
    output = capture_stdout { Gas.print_usage }
    output.should == "Usage: \n"
  end

  it 'should return if correct number of params is supplied' do
    mock(ARGV).length { 3 }
    lambda { Gas.check_parameters( 3, 'Nope') }.should_not raise_error SystemExit
  end

  it 'should exit if incorrect number of params is supplied' do
    mock(ARGV).length { 3 }
    lambda { Gas.check_parameters( 4, 'Error message') }.should raise_error SystemExit
  end

  it 'should list users' do
    any_instance_of(Gas::Users) do |u|
      stub(u).to_s { 'users' }
    end
    output = capture_stdout { Gas.list }
    output.should == "\nAvailable users:\n\nusers\n\n"
  end

  it 'should show current user if any' do
    mock(Gas::GitConfig).current_user { Gas::User.new('foo', 'bar') }
    output = capture_stdout { Gas.show }
    output.should == "Current user:\nfoo <bar>\n"
  end

  it 'should show current user if any' do
    mock(Gas::GitConfig).current_user { nil }
    output = capture_stdout { Gas.show }
    output.should == "No current user in gitconfig\n"
  end

  it 'should exit if no user by nickname exists' do
    any_instance_of(Gas::Users) do |u|
      stub(u).exists?('foo') { false }
    end
    lambda { Gas.use('foo').should be_false }.should raise_error SystemExit
  end

  it 'should use given user' do
    user = Gas::User.new('foo bar', 'foo@bar.com', 'foo')
    any_instance_of(Gas::Users) do |u|
      stub(u).exists?('foo') { true }
      stub(u).get('foo') { user }
    end
    mock(Gas::GitConfig).change_user(user) { }
    mock(Gas::GitConfig).current_user { user }

    output = capture_stdout { Gas.use('foo') }
    output.should == "Current user:\nfoo bar <foo@bar.com>\n"
  end

  it 'should add new user' do
    any_instance_of(Gas::Users) do |u|
      stub(u).exists?('foo') { false }
      stub(u).save! { }
    end
    output = capture_stdout { Gas.add('foo', 'foo bar', 'foo@bar.com') }
    output.should == "Added new author\n      [foo]\n         name = foo bar\n         email = foo@bar.com\n"
  end

  it 'should not add new user if nickname exists' do
    any_instance_of(Gas::Users) do |u|
      stub(u).exists?('foo') { true }
    end
    lambda { Gas.add('foo', 'foo bar', 'foo@bar.com') }.should raise_error SystemExit
  end

  it 'should delete user if nickname exists' do
    any_instance_of(Gas::Users) do |u|
      stub(u).save! { }
    end
    Gas.add('bar', 'foo bar', 'foo@bar.com')
    output = capture_stdout { Gas.delete('bar') }
    output.should == "Deleted author bar\n"
  end

  it 'should import current_user to gas' do
    user = Gas::User.new('foo bar', 'foo@bar.com')
    any_instance_of(Gas::Users) do |u|
      stub(u).exists?('foo') { false }
      stub(u).save! { }
    end
    mock(Gas::GitConfig).current_user { user }

    output = capture_stdout { Gas.import('foo') }
    output.should == "Imported author\n      [foo]\n         name = foo bar\n         email = foo@bar.com\n"
  end

  it 'should not import current_user to gas if no current_user exists' do
    any_instance_of(Gas::Users) do |u|
      stub(u).exists?('foo') { false }
    end
    mock(Gas::GitConfig).current_user { nil }

    output = capture_stdout { Gas.import('foo') }
    output.should == "No current user to import\n"
  end

end