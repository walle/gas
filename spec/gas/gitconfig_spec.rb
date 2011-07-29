require './spec/spec_helper'

require './lib/gas'

describe Gas::Gitconfig do

  before :each do
    @name = 'Fredrik Wallgren'
    @email = 'fredrik.wallgren@gmail.com'
    @gitconfig = Gas::Gitconfig.new
  end

  it 'should be able to get current user from gitconfig' do
    mock_cli_call(@gitconfig, 'git config --global --get user.name') { @name }
    mock_cli_call(@gitconfig, 'git config --global --get user.email') { @email }

    user = @gitconfig.current_user
    user.name.should == @name
    user.email.should == @email
  end

  it 'should return nil if no current user is present in gitconfig' do
    mock_cli_call(@gitconfig, 'git config --global --get user.name') { nil }
    mock_cli_call(@gitconfig, 'git config --global --get user.email') { nil }

    @gitconfig.current_user.should == nil
  end

  it 'should be able to change the current user' do
    name = 'Test Testsson'
    email = 'test@testsson.com'

    mock_cli_call(@gitconfig, "git config --global user.name #{name}") { nil }
    mock_cli_call(@gitconfig, "git config --global user.email #{email}") { nil }
    mock_cli_call(@gitconfig, 'git config --global --get user.name') { name }
    mock_cli_call(@gitconfig, 'git config --global --get user.email') { email }

    @gitconfig.change_user name, email

    user = @gitconfig.current_user
    user.name.should == name
    user.email.should == email
  end
end
