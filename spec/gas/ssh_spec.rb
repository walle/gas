require './spec/spec_helper'

require './lib/gas'

require 'rspec/mocks' 
require 'rspec/mocks/standalone' 

describe Gas::Ssh do
  
  before :each do
    @uid = "teddy"
  end
  
  describe "SSH key file handling" do
    
    describe "Detecting when files are missing" do
      
      before :all do
        File.stub!(:exists?).and_return(false)             # make it so File.exists? always return true
      end
      
      after :all do
        File.unstub!(:exists?)                             # undoes the hook
      end
      
      it "should detect when an id_rsa isn't in the .gas directory" do
        Gas::Ssh.id_rsa_already_in_gas_dir?.should be_false
      end
        
    end
    
    describe "Detecting when files exist" do
      before :all do
        File.stub!(:exists?).and_return(true)             # make it so File.exists? always return true
      end
      
      after :all do
        File.unstub!(:exists?)                             # undoes the hook
      end
      
      it 'should detect when an id_rsa is already in the .gas directory' do
        STDIN.stub!(:gets).and_return("y\n")   # fix stdin to recieve a 'y' command...
        Gas::Ssh.id_rsa_already_in_gas_dir?.should be_true
        STDIN.unstub!(:gets)
      end
      
    end
    
    describe "File System Changes" do
      
      it 'should be able to create ssh keys in .gas'
      
      it 'should be able to copy ssh keys in .ssh'
      
      it 'should be able to swap ssh keys'
        #Ssh.swap_in_rsa(nickname)
      
    end
    
  end
  
    
end