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

end