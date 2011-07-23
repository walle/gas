require './spec/spec_helper'

require './lib/gas'

describe Gas::Gitconfig do

  before :each do
    @name = 'Fredrik Wallgren'
    @email = 'fredrik.wallgren@gmail.com'
    gitconfig = "[other stuff]\n  foo = bar\n\n[user]\n  name = #{@name}\n  email = #{@email}\n\n[foo]\n  bar = foo"
    @gitconfig = Gas::Gitconfig.new gitconfig
    @empty_gitconfig = Gas::Gitconfig.new ''
  end

  it 'should be able to get current user from gitconfig' do
    user = @gitconfig.current_user
    user.name.should == @name
    user.email.should == @email
  end

  it 'should return nil if no current user is present in gitconfig' do
    @empty_gitconfig.current_user.should == nil
  end

  it 'should be able to change the current user' do
    name = 'Test Testsson'
    email = 'test@testsson.com'
    @gitconfig.change_user name, email

    user = @gitconfig.current_user
    user.name.should == name
    user.email.should == email
  end

  it 'should add a new user if no user section exists in gitconfig' do
    name = 'Test Testsson'
    email = 'test@testsson.com'
    @empty_gitconfig.change_user name, email

    user = @empty_gitconfig.current_user
    user.name.should == name
    user.email.should == email
  end

  it 'should not blow up if no gitconfig exists (use empty string instead)' do
    # Stub out File#exists?
    class File
      def self.exists?(path)
        false
      end
    end

    gitconfig_file_absent = Gas::Gitconfig.new
    gitconfig_file_absent.instance_variable_get(:@gitconfig).should == ''
  end
end
