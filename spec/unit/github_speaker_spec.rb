require './spec/spec_helper'
require './lib/gas'


describe Gas::GithubSpeaker do
  
  before :each do
    config = "[#{@nickname}]\n  name = #{@name}\n  email = #{@email}\n\n[user2]\n  name = foo\n  email = bar"
    @config = Gas::Config.new nil, config
    @user = @config.users[0]
    
    @username = "aTestGitAccount"
    @password = "plzdon'thackthetestaccount1"
    
    @sample_rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDn74QR9yHb+hcid8iH3+FTaEwnKtwjttseJDbIA2PaivN2uvESrvHlp8Ss/cRox3fFu34QR5DpdOhlfULjTX7yKVuxhaNrAJaqg8rX8hgr9U1Botnyy1DBueEyyA3o1fxRkmwTf6FNnkt1BxWP635tD0lbmUubwaadXjQqPOf3Uw=="

    VCR.use_cassette('instantiate_github_speaker') do
      @github_speaker = Gas::GithubSpeaker.new(@user, @username, @password)
    end
  end
  
  it "should work"
  
  it 'The post_key! and remove_key! methods should work' do
        
    VCR.use_cassette('githubspeaker-post_key-remove_key', :record => :new_episodes) do # this test has been saved under fixtures/install-delete-a-key.yml
      lambda do
        @github_speaker.post_key! @sample_rsa
      end.should change{get_keys(@username, @password).length}.by(1)
  
      lambda do
        @github_speaker.remove_key! @sample_rsa
      end.should change{get_keys(@username, @password).length}.by(-1)
    end
    
  end
  
  
end