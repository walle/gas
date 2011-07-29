require './spec/spec_helper'

require './lib/gas'

describe Gas::Gitconfig do

  before :each do
    @name = 'Fredrik Wallgren'
    @email = 'fredrik.wallgren@gmail.com'
    @gitconfig = Gas::Gitconfig.new
  end

  it 'should be able to get current user from gitconfig' do
    # To be able to mock ` (http://blog.astrails.com/2010/7/5/how-to-mock-backticks-operator-in-your-test-specs-using-rr)
    mock(@gitconfig).__double_definition_create__.call(:`, 'git config --global --get user.name') { @name }
    mock(@gitconfig).__double_definition_create__.call(:`, 'git config --global --get user.email') { @email }

    user = @gitconfig.current_user
    user.name.should == @name
    user.email.should == @email
  end

  it 'should return nil if no current user is present in gitconfig' do
    mock(@gitconfig).__double_definition_create__.call(:`, 'git config --global --get user.name') { nil }
    mock(@gitconfig).__double_definition_create__.call(:`, 'git config --global --get user.email') { nil }

    @gitconfig.current_user.should == nil
  end

  it 'should be able to change the current user' do
    name = 'Test Testsson'
    email = 'test@testsson.com'

    mock(@gitconfig).__double_definition_create__.call(:`, "git config --global user.name #{name}") { nil }
    mock(@gitconfig).__double_definition_create__.call(:`, "git config --global user.email #{email}") { nil }
    mock(@gitconfig).__double_definition_create__.call(:`, 'git config --global --get user.name') { name }
    mock(@gitconfig).__double_definition_create__.call(:`, 'git config --global --get user.email') { email }

    @gitconfig.change_user name, email

    user = @gitconfig.current_user
    user.name.should == name
    user.email.should == email
  end
end
