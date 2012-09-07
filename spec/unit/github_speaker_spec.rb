require './spec/spec_helper'
require './lib/gas'


describe Gas::GithubSpeaker do
  
  before :each do
    config = "[#{@nickname}]\n  name = #{@name}\n  email = #{@email}\n\n[user2]\n  name = foo\n  email = bar"
    @config = Gas::Config.new nil, config
    @user = @config.users[0]
    
    @username = "aTestGitAccount"               # be VERY careful when plugging in your own testing account here... 
    @password = "plzdon'thackthetestaccount1"   # It will delete ALL keys associated with that account if you run the tests
    
    @sample_rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDn74QR9yHb+hcid8iH3+FTaEwnKtwjttseJDbIA2PaivN2uvESrvHlp8Ss/cRox3fFu34QR5DpdOhlfULjTX7yKVuxhaNrAJaqg8rX8hgr9U1Botnyy1DBueEyyA3o1fxRkmwTf6FNnkt1BxWP635tD0lbmUubwaadXjQqPOf3Uw=="

    VCR.use_cassette('instantiate_github_speaker') do
      @github_speaker = Gas::GithubSpeaker.new(@user, @username, @password)
    end
  end
  
  describe "test keys" do
    
    describe "with no keys..." do
      after :each do
        delete_all_keys_in_github_account!(@github_speaker)
      end
      
      it "should post_key! all the way up to github" do
        initial_length = 'VCR introduces scope =('
        final_length = ''
        
        VCR.use_cassette('get_keys-find_none') do
          initial_length = get_keys(@username, @password).length
        end
        
        VCR.use_cassette('githubspeaker-post_key') do # this test has been saved under fixtures/install-delete-a-key.yml
          @github_speaker.post_key! @sample_rsa
        end
        
        VCR.use_cassette('get_keys-find_one') do
          final_length = get_keys(@username, @password).length
        end
        
        (final_length - initial_length).should be(1)
      end
      
      it "should expose an empty array when no keys..." do
        VCR.use_cassette('check_keys-empty') do
          @github_speaker.keys.empty?.should be_true
        end
      end
      
      it "should expose a key created..." do
        VCR.use_cassette('github_speaker-post_key') do
          @github_speaker.post_key! @sample_rsa
        end
        
        @github_speaker.keys.empty?.should be_false
      end
    end
    
    describe "with a key" do
      before :each do
        VCR.use_cassette('github_speaker-post_key') do
          @github_speaker.post_key! @sample_rsa
        end
        
        @key_id = @github_speaker.keys.first['id']
      end
      
      after :each do
        delete_all_keys_in_github_account!(@github_speaker)
      end
      
      it "should remove_key! from github" do
        initial_length = ''
        final_length = ''
        
        VCR.use_cassette('get_keys-find_one') do
          initial_length = get_keys(@username, @password).length
        end
        
        VCR.use_cassette('githubspeaker-remove_key') do
          @github_speaker.remove_key! @sample_rsa
        end
        
        VCR.use_cassette('get_keys-find_none') do
          final_length = get_keys(@username, @password).length
        end
        
        (final_length - initial_length).should be(-1)
      end
      
      it "should remove a key from @keys", :current => true do
        #require 'pry';binding.pry
        Gas::GithubSpeaker.publicize_methods do
          @github_speaker.remove_key_from_keys @key_id
        end
        
        @github_speaker.keys.empty?.should be_true
      end
    end

  end
  
end