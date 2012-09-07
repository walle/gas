# encoding: utf-8
require 'fileutils'
include FileUtils

# Create a virtual directory in the tmp folder so
# we don't risk damaging files on the running machine
fake_home = '/tmp/gas-virtual-fs'
rm_rf fake_home if File.exists? fake_home
mkdir_p fake_home
mkdir_p fake_home + '/.ssh'
ENV['HOME'] = fake_home


RSpec.configure do |config|
  config.mock_with :rr
end

# Configure VCR, this thing alows you to record HTTP traffic so you never
# Need to connect to a server.  Tests run offline just fine!
require 'vcr'

VCR.configure do |c|
  #c.allow_http_connections_when_no_cassette = true    # set to true if you're refreshing the cassets in fixtures
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
end


# Mocks a cli call using ` with rr.
# Takes a block to use as rr return block
# @param [Object] mock_object The object to mock
# @param [String] command The command to mock
def mock_cli_call(mock_object, command)
  # To be able to mock ` (http://blog.astrails.com/2010/7/5/how-to-mock-backticks-operator-in-your-test-specs-using-rr)
  mock(mock_object).__double_definition_create__.call(:`, command) { yield }
end


# Obsolete, using virtual file directory now
def move_the_testers_personal_ssh_key_out_of_way
  if File.exists?(SSH_DIRECTORY + "/id_rsa") 
    @pattern_to_restore_privl = File.open(SSH_DIRECTORY + "/id_rsa","r").read      # this test requires some juggling of files that may already exist.
    File.open(GAS_DIRECTORY + "/temp_test","w+").puts @pattern_to_restore_privl
    File.delete(SSH_DIRECTORY + "/id_rsa")
  end
  
  if File.exists?(SSH_DIRECTORY + "/id_rsa.pub")
    @pattern_to_restore_publ = File.open(SSH_DIRECTORY + "/id_rsa.pub","r").read   # We don't want to mess things up for the tester, so we will need to save these files and then delete them
    File.open(GAS_DIRECTORY + "/temp_test.pub","w+").puts @pattern_to_restore_publ
    File.delete(SSH_DIRECTORY + "/id_rsa.pub")
  end
end


# Obsolete, using virtual file directory now
def restore_the_testers_ssh_key
  if File.exists?(GAS_DIRECTORY + "/temp_test") 
    @pattern_to_restore_privl = File.open(GAS_DIRECTORY + "/temp_test","r").read      # this test requires some juggling of files that may already exist.
    File.open(SSH_DIRECTORY + "/id_rsa","w+").puts @pattern_to_restore_privl
    File.delete(GAS_DIRECTORY + "/temp_test")
  end
  
  if File.exists?(GAS_DIRECTORY + "/temp_test.pub")
    @pattern_to_restore_publ = File.open(GAS_DIRECTORY + "/temp_test.pub","r").read   # We don't want to mess things up for the tester, so we will need to save these files and then delete them
    File.open(SSH_DIRECTORY + "/id_rsa.pub","w+").puts @pattern_to_restore_publ
    File.delete(GAS_DIRECTORY + "/temp_test.pub")
  end
end


def clean_out_ssh_directory
  if File.exists?(SSH_DIRECTORY + "/id_rsa") 
    File.delete(SSH_DIRECTORY + "/id_rsa")
  end
  
  if File.exists?(SSH_DIRECTORY + "/id_rsa.pub")
    File.delete(SSH_DIRECTORY + "/id_rsa.pub")      
  end
end

def clean_out_gas_directory(nickname)
  if File.exists?(GAS_DIRECTORY + "/#{nickname}_id_rsa") 
    File.delete(GAS_DIRECTORY + "/#{nickname}_id_rsa")
  end
  
  if File.exists?(SSH_DIRECTORY + "/#{nickname}_id_rsa.pub")
    File.delete(@ssh_dir + "/#{nickname}_id_rsa.pub")      
  end
end

# this function either mutates an existing file, or creates a new file that won't
# have been backed up by gas
def plant_bogus_rsa_keys_in_ssh_directory
  id_rsa = "this rsa file is bogus and not backed up by .gas yet"
  id_rsa_pub = "this pub rsa file is bogus and not backed up by .gas yet"

  File.open(SSH_DIRECTORY + "/id_rsa","w+") do |f|
    f.puts id_rsa
  end
  
  File.open(SSH_DIRECTORY + "/id_rsa.pub","w+") do |f|
    f.puts id_rsa_pub
  end
  
  return [id_rsa, id_rsa_pub]
end


def create_user_no_git(nickname, name, email)
    Gas::Prompter.stub!(:user_wants_gas_to_handle_rsa_keys?).and_return(true)
    #Gas::Ssh.stub!(:user_wants_to_use_key_already_in_ssh?).and_return(false)
    Gas::Prompter.stub!(:user_wants_to_install_key_to_github?).and_return(false)
    
    Gas.add(nickname,name,email)
    
    Gas::Prompter.unstub!(:user_wants_gas_to_handle_rsa_keys?)
    #Gas::Ssh.unstub!(:user_wants_to_use_key_already_in_ssh?)
    Gas::Prompter.unstub!(:user_wants_to_install_key_to_github?)
end

# toasts ssh keys for a given nickname and removal from gas.authors
def delete_user_no_git(nickname)
  Gas.delete(nickname)
end


# Cycles through github, looking to see if rsa exists as a public key, then deletes it if it does
def remove_key_from_github_account(username, password, rsa)
  # get all keys
  keys = Gas::Ssh.get_keys(username, password)
  # loop through arrays checking against 'key'
  keys.each do |key|
      if key["key"] == rsa
        return Gas::Ssh.remove_key_by_id!(username, password, key["id"])
      end
  end

  return false   # key not found
end

def delete_all_keys_in_github_account!(github_speaker)
  VCR.use_cassette('delete_all_keys_in_github_account', :record => :new_episodes) do
    github_speaker.keys.each do |key|
      Gas::GithubSpeaker.publicize_methods do
        github_speaker.remove_key_by_id! key['id']
      end
    end
  end
end

def get_keys(username, password)
  server = 'api.github.com'
  path = '/user/keys'


  http = Net::HTTP.new(server,443)
  req = Net::HTTP::Get.new(path)
  http.use_ssl = true
  req.basic_auth username, password
  response = http.request(req)

  return JSON.parse(response.body)
end


# This is used for publicizing the methods of a class so you can use TDD for projects, even in RUBY!
class Class
  def publicize_methods
    saved_private_instance_methods = self.private_instance_methods
    self.class_eval { public *saved_private_instance_methods }
    yield
    self.class_eval { private *saved_private_instance_methods }
  end
end
