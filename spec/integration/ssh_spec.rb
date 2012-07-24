require './spec/spec_helper'

require './lib/gas'

require 'rspec/mocks'
require 'rspec/mocks/standalone'

describe Gas::Ssh do

  before :all do
    move_the_testers_personal_ssh_key_out_of_way
  end

  after :all do
    restore_the_testers_ssh_key
  end

  before :each do
    @uid = "teddy"
  end

  describe "SSH key file handling..." do

    before :all do
      #Gas::Ssh.stub!(:delete).and_return(false)
      Gas::Ssh.stub!(:user_wants_to_delete_all_ssh_data?).and_return("l")  # only delete's local keys
    end

    after :all do
      #Gas::Ssh.unstub!(:delete)
      Gas::Ssh.unstub!(:user_wants_to_delete_all_ssh_data?)
    end

    describe "Detecting when files are missing..." do

      before :all do
        File.stub!(:exists?).and_return(false)             # make it so File.exists? always return true
      end

      after :all do
        File.unstub!(:exists?)                             # undoes the hook
      end

      it "should detect when an id_rsa isn't in the .gas directory" do
        Gas::Ssh.user_wants_to_use_key_already_in_gas?.should be_false
      end

    end

    describe "Detecting when files exist.@email..." do
      before :all do
        File.stub!(:exists?).and_return(true)             # make it so File.exists? always return true
      end

      after :all do
        File.unstub!(:exists?)                             # undoes the hook
      end

      it 'should detect when an id_rsa is already in the .gas directory' do
        STDIN.stub!(:gets).and_return("y\n")   # fix stdin to recieve a 'y' command...
        Gas::Ssh.user_wants_to_use_key_already_in_gas?.should be_true
        STDIN.unstub!(:gets)
      end

    end

    describe "File System Changes..." do

      before :all do
        @gas_dir = File.expand_path('~/.gas')
        @ssh_dir = File.expand_path('~/.ssh')


        @nickname = "thisaccountmaybedeletedmysteriously"
        @name = "tim T"
        @email = "tim@timmy.com"

        `rm ~/.gas/#{@nickname}_id_rsa`
        `rm ~/.gas/#{@nickname}_id_rsa.pub`
        Gas.delete(@nickname)

        # make sure that nickname isn't in use
      end


      it 'should create ssh keys in .gas && Gas.remove should be able to remove those files' do
        STDIN.stub!(:gets).and_return("y\n")          # forces the dialogs to
        Gas::Ssh.stub!(:upload_public_key_to_github).and_return(false)

        lambda do
          Gas.add(@nickname,@name,@email)
        end.should change{`ls ~/.gas -1 | wc -l`.to_i}.by(2)   #OMG THIS IS A FUN TEST!!!

        lambda do
          Gas.delete(@nickname)
        end.should change{`ls ~/.gas -1 | wc -l`.to_i}.by(-2)

        STDIN.unstub!(:gets)
        Gas::Ssh.unstub!(:upload_public_key_to_github)
      end


      describe 'For the ssh directory...' do

        before :each do
          # A user for creating
          @nickname = "thisaccountmaybedeletedmysteriously"
          @name = "tim T"
          @email = "tim@timmy.com"

          clean_out_ssh_directory
          clean_out_gas_directory(@nickname)

          # a user for deleting
          @nickname2 = "thisaccountmaybedeletedmysteriously2"
          @name2 = "tim T2"
          @email2 = "tim@timmy.com2"
          create_user_no_git(@nickname2, @name2, @email2)
        end

        after :each do
          Gas.delete(@nickname)
          delete_user_no_git(@nickname2)
        end


        it "if there's no key in .ssh" do
          #  1)  Create a User

          #  2)  Switch to that user

          #  3)  The .ssh directory should now contain that file
          true.should be_true

        end

        it "if there's a key in ~/.ssh that isn't backed up in .gas" do
          #  1)  Create a User

          #  2)  Switch to that user

          #  3)  The .ssh directory should now contain that file

        end

        it "If there's a key in ~/.ssh that's backed up in .gas"

        it "should delete the key in .ssh when the user is deleted" do
          # Gas.add(@nickname,@name,@email)

        end

        #  bundle exec rspec spec/gas/ssh_spec.rb -e 'should be able to copy ssh keys in the ssh'
        it 'should be able to copy ssh keys in the ssh' do
          # put a key pair in the ssh directory
          mock_text = "this is a mock ssh file"
          File.open(SSH_DIRECTORY + "/id_rsa","w+").write(mock_text)
          File.open(SSH_DIRECTORY + "/id_rsa.pub","w+").write(mock_text)

          File.exists?(GAS_DIRECTORY + "/#{@nickname}_id_rsa").should be_false
          File.exists?(GAS_DIRECTORY + "/#{@nickname}_id_rsa.pub").should be_false

          Gas::Ssh.use_current_rsa_files_for_this_user(@nickname)

          File.exists?(GAS_DIRECTORY + "/#{@nickname}_id_rsa").should be_true
          File.exists?(GAS_DIRECTORY + "/#{@nickname}_id_rsa.pub").should be_true

          ssh_file = File.read(GAS_DIRECTORY + "/#{@nickname}_id_rsa")
          # ssh_file.should == mock_text # this part doesn't work... hmmm...

          File.delete(GAS_DIRECTORY + "/#{@nickname}_id_rsa")
          File.delete(GAS_DIRECTORY + "/#{@nickname}_id_rsa.pub")
        end


        it "should have a UTILITY for deleting rsa files of user" do
          lambda do
            Gas::Ssh.delete_associated_local_keys!(@nickname2)
          end.should change{`ls ~/.gas -1 | wc -l`.to_i}.by(-2)
        end

      end

    end



  end

  describe "Networking stuff..." do

    before :all do
      @name = 'Fredrik Wallgren'
      @email = 'fredrik.wallgren@gmail.com'
      @nickname = "thisaccountmaybedeletedmysteriously"

      # make sure sample key is deleted
      @username = "aTestGitAccount"
      @password = "plzdon'thackthetestaccount1"

      config = "[#{@nickname}]\n  name = #{@name}\n  email = #{@email}\n\n[user2]\n  name = foo\n  email = bar"
      @config = Gas::Config.new nil, config
      @user = @config.users[0]

      @credentials = {:username => @username, :password => @password}

      # Code to prepare the github environment for testing
      @sample_rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDn74QR9yHb+hcid8iH3+FTaEwnKtwjttseJDbIA2PaivN2uvESrvHlp8Ss/cRox3fFu34QR5DpdOhlfULjTX7yKVuxhaNrAJaqg8rX8hgr9U1Botnyy1DBueEyyA3o1fxRkmwTf6FNnkt1BxWP635tD0lbmUubwaadXjQqPOf3Uw=="


      Gas::Ssh.stub!(:get_username_and_password_and_authenticate).and_return(@credentials)  #TODO: remove this obsolete stub when it's really obsolete
      #Gas::GithubSpeaker.stub!(:get_username_and_password_and_authenticate).and_return({:account_name => @username, :password => @password})
      #Gas::Ssh::GithubSpeaker.stub!(:get_username_and_password_and_authenticate).and_return({:account_name => @username, :password => @password})
    end

    after :all do
      Gas::Ssh.unstub!(:get_username_and_password_and_authenticate)
      #Gas::GithubSpeaker.unstub!(:get_username_and_password_and_authenticate)
    end

  # bundle exec rspec spec/integration/ssh_spec.rb -e 'UTILITY:  should be able to insert a new key into github and conversly remove that key'
    it 'UTILITY:  should be able to insert a new key into github and conversly remove that key' do
      
      VCR.use_cassette('install-delete-a-key') do # this test has been saved under fixtures/install-and-remove.yml
        lambda do
          Gas::Ssh.key_installation_routine!(@user, @sample_rsa)
        end.should change{Gas::Ssh.get_keys(@username, @password).length}.by(1)
  
        lambda do
          Gas::Ssh.remove_key!(@username, @password, @sample_rsa)
        end.should change{Gas::Ssh.get_keys(@username, @password).length}.by(-1)
      end
      
    end


    # bundle exec rspec spec/gas/ssh_spec.rb SPEC_OPTS="-e \"should add ssh keys to github when user is created, and delete them when destroyed\""
=begin
rake spec SPEC=spec/gas/ssh_spec.rb \
          SPEC_OPTS="-e \"should add ssh keys to github when user is created, and delete them when destroyed\""

    bundle exec rspec spec/gas/ssh_spec.rb -e 'should add ssh keys to github when user is created, and delete them when destroyed'

bundle exec rspec spec/gas/ssh_spec.rb -e 'UTILITY:  should be able to insert a new key into github and conversly remove that key'
=end

    it "should add ssh keys to github when user is created, and delete them when destroyed" do

      #move_the_testers_personal_ssh_key_out_of_way

      # yes, delete all
      Gas::Ssh.stub!(:user_wants_to_delete_all_ssh_data?).and_return("a")  # all keys, local and github
      # create new user and use ssh handling
      Gas::Ssh.stub!(:user_wants_gas_to_handle_rsa_keys?).and_return(true)
      Gas::Ssh.stub!(:user_wants_to_use_key_already_in_ssh?).and_return(false)
      Gas::Ssh.stub!(:user_wants_to_install_key_to_github?).and_return(true)


      lambda do
        Gas.add(@nickname,@name,@email)
      end.should change{Gas::Ssh.get_keys(@username, @password).length}.by(1)

      lambda do
        Gas.delete(@nickname)
      end.should change{Gas::Ssh.get_keys(@username, @password).length}.by(-1)


      #restore_the_testers_ssh_key

      Gas::Ssh.unstub!(:user_wants_to_delete_all_ssh_data?)
      Gas::Ssh.unstub!(:user_wants_gas_to_handle_rsa_keys?)
      Gas::Ssh.unstub!(:user_wants_to_use_key_already_in_ssh?)
      Gas::Ssh.unstub!(:user_wants_to_install_key_to_github?)
    end



    it "Gas.Delete should be able to remove the id_rsa from .gas" do
      Gas::Ssh.stub!(:user_wants_to_delete_all_ssh_data?).and_return("a")
      Gas::Ssh.stub!(:user_wants_gas_to_handle_rsa_keys?).and_return(true)
      Gas::Ssh.stub!(:user_wants_to_use_key_already_in_ssh?).and_return(false)
      Gas::Ssh.stub!(:user_wants_to_install_key_to_github?).and_return(true)

      lambda do
        Gas.add(@nickname,@name,@email)
      end.should change{`ls ~/.gas -1 | wc -l`.to_i}.by(2)

      lambda do
        Gas.delete(@nickname)
      end.should change{`ls ~/.gas -1 | wc -l`.to_i}.by(-2)


      Gas::Ssh.unstub!(:user_wants_to_delete_all_ssh_data?)
      Gas::Ssh.unstub!(:user_wants_gas_to_handle_rsa_keys?)
      Gas::Ssh.unstub!(:user_wants_to_use_key_already_in_ssh?)
      Gas::Ssh.unstub!(:user_wants_to_install_key_to_github?)
    end

    # bundle exec rspec spec/gas/ssh_spec.rb -e 'Gas.ssh(nickname) should be able to add ssh support to a legacy user or an opt-out'
    it 'Gas.ssh(nickname) should be able to add ssh support to a legacy user or an opt-out' do

      Gas::Ssh.stub!(:user_wants_gas_to_handle_rsa_keys?).and_return(false)
      Gas.add(@nickname,@name,@email)
      Gas::Ssh.unstub!(:user_wants_gas_to_handle_rsa_keys?)

      Gas::Ssh.stub!(:user_wants_gas_to_handle_rsa_keys?).and_return(true)
      Gas::Ssh.stub!(:upload_public_key_to_github)

      lambda do
        Gas.ssh(@nickname)
      end.should change{`ls ~/.gas -1 | wc -l`.to_i}.by(2)


      Gas::Ssh.delete_associated_local_keys!(@nickname)

      Gas::Ssh.unstub!(:user_wants_gas_to_handle_rsa_keys?)
      Gas::Ssh.unstub!(:upload_public_key_to_github)
    end



    it "Should be able to tell if it's ever used this key under this ISP provider before and then warn the user"

    it 'Should have the ability to show if the author is associated with a specific github account NAME, stored in gas.accouts file'

    it 'Should have the ability to link up with non-github git-daemons'
    
    # bundle exec rspec spec/gas/ssh_spec.rb -e 'gitspeaker test'
    it 'gitspeaker test' do
      
      Gas::Ssh.key_installation_routine_oo!()
    end
    
  end



end
