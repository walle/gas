require './spec/spec_helper'

require './lib/gas'

require 'rspec/mocks' 
require 'rspec/mocks/standalone' 

describe Gas::Ssh do
  
  before :each do
    @uid = "teddy"
  end
  
  describe "SSH key file handling..." do
    
    describe "Detecting when files are missing..." do
      
      before :all do
        File.stub!(:exists?).and_return(false)             # make it so File.exists? always return true
      end
      
      after :all do
        File.unstub!(:exists?)                             # undoes the hook
      end
      
      it "should detect when an id_rsa isn't in the .gas directory" do
        Gas::Ssh.id_rsa_already_in_gas_dir_for_use?.should be_false
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
        Gas::Ssh.id_rsa_already_in_gas_dir_for_use?.should be_true
        STDIN.unstub!(:gets)
      end
      
    end
    
    describe "File System Changes..." do
      
      before :all do
        @gas_dir = File.expand_path('~/.gas')
        @ssh_dir = File.expand_path('~/.ssh')
        
        if File.exists?(SSH_DIRECTORY + "/id_rsa") 
          @pattern_to_restore_privl = File.open(@ssh_dir + "/id_rsa","r").read      # this test requires some juggling of files that may already exist.
        end
        
        if File.exists?(SSH_DIRECTORY + "/id_rsa.pub")
          @pattern_to_restore_publ = File.open(@ssh_dir + "/id_rsa.pub","r").read   # We don't want to mess things up for the tester, so we will need to save these files and then delete them
        end
        
        
        
        @nickname = "thisaccountmaybedeletedmysteriously"
        @name = "tim T"
        @email = "tim@timmy.com"
        
        `rm ~/.gas/#{@nickname}_id_rsa`
        `rm ~/.gas/#{@nickname}_id_rsa.pub`
        Gas.delete(@nickname)     
        
        # make sure that nickname isn't in use
      end
      
      after :all do
        
      end
      
      it 'should create ssh keys in .gas && Gas.remove should be able to remove those files' do
        
        STDIN.stub!(:gets).and_return("y\n")          # forces the dialogs to  
        
        lambda do
          Gas.add(@nickname,@name,@email)
        end.should change{`ls ~/.gas -1 | wc -l`.to_i}.by(2)   #OMG THIS IS A FUN TEST!!!
        
        lambda do
          Gas.delete(@nickname)
        end.should change{`ls ~/.gas -1 | wc -l`.to_i}.by(-2)
          
        STDIN.unstub!(:gets)
      end

            
      describe 'For the ssh directory...' do
        
        before :all do    # temporarily clear out the ~/.ssh files for testing
          
          if File.exists?(SSH_DIRECTORY + "/id_rsa") 
            #@pattern_to_restore_privl = File.open(@ssh_dir + "/id_rsa","r").read      # this test requires some juggling of files that may already exist.
            File.delete(@ssh_dir + "/id_rsa")
          end
          
          if File.exists?(SSH_DIRECTORY + "/id_rsa.pub")
            #@pattern_to_restore_publ = File.open(@ssh_dir + "/id_rsa.pub","r").read   # We don't want to mess things up for the tester, so we will need to save these files and then delete them
            File.delete(@ssh_dir + "/id_rsa.pub")      
          end
          
          
          @nickname = "thisaccountmaybedeletedmysteriously"
          @name = "tim T"
          @email = "tim@timmy.com"
          
          # setup the stubs
          
          
          # Gas.add(@nickname,@name,@email)
        end
        
        after :all do      # replace the .ssh directory to be the way it was before.  
          Gas.delete(@nickname)
          
          # this test requires some juggling of files that may already exist.  These lines should restore the original rsa and rsa.pub files
          File.open(@ssh_dir + "/id_rsa", "w+").puts(@pattern_to_restore_privl) unless @pattern_to_restore_privl.nil?             
          File.open(@ssh_dir + "/id_rsa.pub","w+").puts(@pattern_to_restore_publ) unless @pattern_to_restore_publ.nil?
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
        
        
        it 'should be able to copy ssh keys in ~/.ssh' do 
          # put a key pair in the ssh directory
          mock_text = "this is a mock ssh file"
          File.open(@ssh_dir + "/id_rsa","w").write(mock_text)
          File.open(@ssh_dir + "/id_rsa.pub","w").write(mock_text)
          
          @uid = @nickname  # hopefully uid gets passed in there... otherwise I gotta re-engineer the way that function works again
          Gas::Ssh.use_current_rsa_files_for_this_user
          
          ssh_file = File.open(@ssh_dir + "/id_rsa","r").read
          
          
        end
        
        
      end
        #Ssh.swap_in_rsa(nickname)
      
    end
    
    
    
  end
  
  it "Should be able to tell if it's ever used this key under this ISP provider before and then warn the user"
    
end