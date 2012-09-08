require './spec/spec_helper'

require './lib/gas'

require 'rspec/mocks'
require 'rspec/mocks/standalone'
require 'pry'


describe Gas::Ssh do
  before :all do
    @nickname = "thisaccountmaybedeletedmysteriously"
    @name = "tim T"
    @email = "tim@timmy.com"
  end
  
  before :each do
    @uid = "teddy"
  end

  describe "SSH key file handling..." do

    before :all do
      Gas::Prompter.stub!(:user_wants_to_delete_all_ssh_data?).and_return("l")  # only delete's local keys
    end

    after :all do
      Gas::Prompter.unstub!(:user_wants_to_delete_all_ssh_data?)
    end

    describe "Detecting when files are missing..." do
      it "should detect when an id_rsa isn't in the .gas directory" do
        Gas::Ssh.corresponding_rsa_files_exist?(@uid).should be_false
      end
    end

    describe "Detecting when files exist..." do
      before :each do
        create_user_no_git @uid, @uid, "a@b.com"
      end

      after :each do
        delete_user_no_git @uid
      end

      it 'should detect when an id_rsa is already in the .gas directory' do
        Gas::Ssh.corresponding_rsa_files_exist?(@uid).should be_true
      end
    end

    describe "File System Changes..." do
      
      it 'should create ssh keys in .gas && Gas.remove should be able to remove those files' do
        STDIN.stub!(:gets).and_return("y\n")          # forces the dialogs to
        Gas::Ssh.stub!(:upload_public_key_to_github).and_return(false)

        lambda do
          Gas.add(@nickname,@name,@email)
        end.should change{count_of_files_in(GAS_DIRECTORY)}.by(2)

        lambda do
          Gas.delete(@nickname)
        end.should change{count_of_files_in(GAS_DIRECTORY)}.by(-2)

        STDIN.unstub!(:gets)
        Gas::Ssh.unstub!(:upload_public_key_to_github)
      end


      describe 'For the ssh directory...' do
        before :each do
          clean_out_ssh_directory
          clean_out_gas_directory(@nickname)

          # a second user for deleting
          @nickname2 = "thisaccountmaybedeletedmysteriously2"
          @name2 = "tim T2"
          @email2 = "tim@timmy.com2"
          
          create_user_no_git(@nickname2, @name2, @email2)
        end

        after :each do
          Gas.delete(@nickname)
          delete_user_no_git(@nickname2)
        end


        it "if there's no key in .ssh, the use command should place a key there" do
          
          Gas.use @nickname2
          #  3)  The .ssh directory should now contain that file
          File.exist?(SSH_DIRECTORY + "/id_rsa.pub").should be_true
        end

        it "shouldn't overwrite an existing key in ~/.ssh that isn't backed up in .gas and the user aborts" do
          #  2)  Create a bogus id_rsa in the .ssh directory
          id_rsa, id_rsa_pub = plant_bogus_rsa_keys_in_ssh_directory
          #  3)  Switch to that user
          Gas::Prompter.stub!(:user_wants_to_overwrite_existing_rsa_key?).and_return(false)
          Gas.use @nickname2
          Gas::Prompter.unstub!(:user_wants_to_overwrite_existing_rsa_key?)
          #  4)  The .ssh directory should not be changed
          File.open(SSH_DIRECTORY + "/id_rsa", "r") do |f|
            f.read.strip.should eq id_rsa
          end
          File.open(SSH_DIRECTORY + "/id_rsa.pub", "r") do |f|
            f.read.strip.should eq id_rsa_pub
          end
        end

        it "should overwrite an existing, unbacked-up key in ~/.ssh if user wants" do
          #  2)  Create a bogus id_rsa in the .ssh directory
          id_rsa, id_rsa_pub = plant_bogus_rsa_keys_in_ssh_directory
          #  3)  Switch to that user
          Gas::Prompter.stub!(:user_wants_to_overwrite_existing_rsa_key?).and_return(true)
          Gas.use @nickname2
          Gas::Prompter.unstub!(:user_wants_to_overwrite_existing_rsa_key?)
          #  4)  The .ssh directory should not be changed
          File.open(SSH_DIRECTORY + "/id_rsa", "r") do |f|
            f.read.strip.should_not eq id_rsa
          end
        end

        it "If there's a key in ~/.ssh that's backed up in .gas" do
          # 1) Create an alternate user
          create_user_no_git(@nickname, @name, @email)
          rsa, rsa_pub = Gas::Ssh.get_associated_rsa_key(@nickname)
          rsa2, rsa2_pub = Gas::Ssh.get_associated_rsa_key(@nickname2)
          # 2) 
          Gas.use @nickname2
          File.open(SSH_DIRECTORY + "/id_rsa.pub", "r") do |f|
            f.read.strip.should eq rsa2
          end
          Gas.use @nickname
          File.open(SSH_DIRECTORY + "/id_rsa.pub", "r") do |f|
            f.read.strip.should eq rsa
          end
        end

        it "should delete the key in .ssh when the user is deleted" do
          create_user_no_git(@nickname, @name, @email)
          File.exists?(GAS_DIRECTORY + "/#{@nickname}_id_rsa").should be_true
          Gas.delete @nickname
          File.exists?(GAS_DIRECTORY + "/#{@nickname}_id_rsa").should be_false
        end

        it 'should be able to copy ssh keys in the ssh' do
          # put a key pair in the ssh directory
          mock_text = "this is a mock ssh file"
          File.open(SSH_DIRECTORY + "/id_rsa","w+") do |f|
            f.write(mock_text)
          end
          File.open(SSH_DIRECTORY + "/id_rsa.pub","w+") do |f|
            f.write(mock_text)
          end

          File.exists?(GAS_DIRECTORY + "/#{@nickname}_id_rsa").should be_false
          File.exists?(GAS_DIRECTORY + "/#{@nickname}_id_rsa.pub").should be_false
          
          Gas::Ssh.use_current_rsa_files_for_this_user(@nickname)

          File.exists?(GAS_DIRECTORY + "/#{@nickname}_id_rsa").should be_true
          File.exists?(GAS_DIRECTORY + "/#{@nickname}_id_rsa.pub").should be_true

          File.read(GAS_DIRECTORY + "/#{@nickname}_id_rsa") do |f|
            f.read.should == mock_text # this part doesn't work... hmmm...
          end

          File.delete(GAS_DIRECTORY + "/#{@nickname}_id_rsa")
          File.delete(GAS_DIRECTORY + "/#{@nickname}_id_rsa.pub")
        end

        

        it "should have a UTILITY for deleting rsa files of user" do
          lambda do
            Gas::Ssh.delete_associated_local_keys!(@nickname2)
          end.should change{count_of_files_in(GAS_DIRECTORY)}.by(-2)
        end
      end

    end

  end

  describe "Networking stuff..." do
    before :all do
      # make sure sample key is deleted in the github web client if you incur issues
      @username = "aTestGitAccount"
      @password = "plzdon'thackthetestaccount1"

      config = "[#{@nickname}]\n  name = #{@name}\n  email = #{@email}\n\n[user2]\n  name = foo\n  email = bar"
      @config = Gas::Config.new nil, config
      @user = @config.users[0]

      @credentials = {:username => @username, :password => @password}

      # Code to prepare the github environment for testing
      @sample_rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDn74QR9yHb+hcid8iH3+FTaEwnKtwjttseJDbIA2PaivN2uvESrvHlp8Ss/cRox3fFu34QR5DpdOhlfULjTX7yKVuxhaNrAJaqg8rX8hgr9U1Botnyy1DBueEyyA3o1fxRkmwTf6FNnkt1BxWP635tD0lbmUubwaadXjQqPOf3Uw=="

      Gas.delete(@nickname)
      Gas::Ssh.stub!(:get_username_and_password_and_authenticate).and_return(@credentials)
      
      VCR.use_cassette('instantiate_github_speaker', :record => :new_episodes) do
        @github_speaker = Gas::GithubSpeaker.new(@user, @username, @password)
      end
    end

    after :all do
      Gas.delete(@nickname)
      Gas::Ssh.unstub!(:get_username_and_password_and_authenticate)
    end

    describe "Should remove and insert keys into github" do
      it 'UTILITY:  should insert a new key into github and conversly remove that key' do
        initial_request = ''
        subsequent_request = ''
        
        VCR.use_cassette('get_keys-find_none') do
          initial_request = get_keys(@username, @password).length
        end
        
        VCR.use_cassette('key_installation_routine-Add_key', :record => :new_episodes) do
          Gas::Ssh.key_installation_routine!(@user, @sample_rsa, @github_speaker)
        end
        
        VCR.use_cassette('get_keys-find_one') do
          subsequent_request = get_keys(@username, @password).length
        end
        
        (subsequent_request - initial_request).should be(1)
      end
      
      it 'should remove the key that it just inserted, so DONT RUN ALONE' do
        initial_request = ''
        subsequent_request = ''
        
        VCR.use_cassette('get_keys-find_one') do
          initial_request = get_keys(@username, @password).length
        end
        
        VCR.use_cassette('key_installation_routine-Remove_key') do
          lambda do
            @github_speaker.remove_key! @sample_rsa
          end.should change{get_keys(@username, @password).length}.by(-1)
        end
        
        VCR.use_cassette('get_keys-find_none') do
          subsequent_request = get_keys(@username, @password).length
        end
        
        (subsequent_request - initial_request).should be(-1)
      end
      
    end


    it "should add ssh keys to github when user is created, and delete them when destroyed" do
      # yes, delete all
      Gas::Prompter.stub!(:user_wants_to_delete_all_ssh_data?).and_return("a")  # all keys, local and github
      # create new user and use ssh handling
      Gas::Prompter.stub!(:user_wants_gas_to_handle_rsa_keys?).and_return(true)
      Gas::Prompter.stub!(:user_wants_to_use_key_already_in_ssh?).and_return(false)
      Gas::Prompter.stub!(:user_wants_to_install_key_to_github?).and_return(true)

      VCR.use_cassette('add-on-crteation-delete-on-deletion', :record => :new_episodes) do 
        lambda do
          Gas.add(@nickname,@name,@email, @github_speaker)
        end.should change{get_keys(@username, @password).length}.by(1)

        lambda do
          Gas::Ssh.stub!(:get_nils).and_return({ :username => @username, :password => @password })
          Gas.delete(@nickname)
          Gas::Ssh.unstub!(:get_nils)
        end.should change{get_keys(@username, @password).length}.by(-1)
      end

      Gas::Prompter.unstub!(:user_wants_to_delete_all_ssh_data?)
      Gas::Prompter.unstub!(:user_wants_gas_to_handle_rsa_keys?)
      Gas::Prompter.unstub!(:user_wants_to_use_key_already_in_ssh?)
      Gas::Prompter.unstub!(:user_wants_to_install_key_to_github?)
    end

    it "Gas.Delete should be able to remove the id_rsa from .gas" do
      Gas::Prompter.stub!(:user_wants_to_delete_all_ssh_data?).and_return("a")
      Gas::Prompter.stub!(:user_wants_gas_to_handle_rsa_keys?).and_return(true)
      Gas::Prompter.stub!(:user_wants_to_use_key_already_in_ssh?).and_return(false)
      Gas::Prompter.stub!(:user_wants_to_install_key_to_github?).and_return(true)

      VCR.use_cassette('add-on-crteation-delete-on-deletion') do 
        lambda do
          Gas.add(@nickname,@name,@email, @github_speaker)
        end.should change{count_of_files_in(GAS_DIRECTORY)}.by(2)
  
        lambda do
          Gas::Ssh.stub!(:get_nils).and_return({:username => @username, :password => @password })
          Gas.delete(@nickname)
          Gas::Ssh.unstub!(:get_nils)
        end.should change{count_of_files_in(GAS_DIRECTORY)}.by(-2)
      end

      Gas::Prompter.unstub!(:user_wants_to_delete_all_ssh_data?)
      Gas::Prompter.unstub!(:user_wants_gas_to_handle_rsa_keys?)
      Gas::Prompter.unstub!(:user_wants_to_use_key_already_in_ssh?)
      Gas::Prompter.unstub!(:user_wants_to_install_key_to_github?)
    end

    it 'Gas.ssh(nickname) should be able to add ssh support to a legacy user or an opt-out' do
      Gas::Prompter.stub!(:user_wants_gas_to_handle_rsa_keys?).and_return(false)
      Gas.add(@nickname,@name,@email)
      Gas::Prompter.unstub!(:user_wants_gas_to_handle_rsa_keys?)

      Gas::Prompter.stub!(:user_wants_gas_to_handle_rsa_keys?).and_return(true)
      Gas::Ssh.stub!(:upload_public_key_to_github)

      lambda do
        Gas.ssh(@nickname)
      end.should change{count_of_files_in(GAS_DIRECTORY)}.by(2)

      Gas::Ssh.delete_associated_local_keys!(@nickname)

      Gas::Prompter.unstub!(:user_wants_gas_to_handle_rsa_keys?)
      Gas::Ssh.unstub!(:upload_public_key_to_github)
    end



    it "Should be able to tell if it's ever used this key under this ISP provider before and then warn the user"

    it 'Should have the ability to show if the author is associated with a specific github account NAME, stored in gas.accouts file'

    it 'Should have the ability to link up with non-github git-daemons'

  end


end
