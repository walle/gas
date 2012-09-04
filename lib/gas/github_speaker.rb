module Gas
  # A beautiful class that makes working with the github API an enjoyable experience
  class GithubSpeaker
    attr_reader :user, :account_name, :password, :keys, :status
    attr_accessor :server
    
    def keys
      refresh_keys if @keys.nil?
      @keys
    end
    
    def initialize(user, account_name=nil, password=nil, server = 'api.github.com')
      @user = user
      @server = server
      @keys = nil
      
      # sort out username and password...  Make it's own function?
      if account_name.nil? and password.nil?
        # Prompt for username and password
        credentials = get_username_and_password_diligently
        @account_name = credentials[:account_name]            # this overwrite happens twice to make testing easier...  Stub on get_username, kekeke
        @password = credentials[:password]
      else
        @account_name = account_name
        @password = password
        authenticate
      end
      
    end
    
    
    def post_key!(rsa)
      refresh_keys if @keys.nil? 
      
      puts "Posting key to GitHub.com..."
  
      #  find key...
      if has_key(rsa)
        puts "Key already installed."
        return false
      end      
      title = "GAS: #{@user.nickname}"
      result = install_key(rsa)
      
      if result != false
        @keys << result
        return true
      end
    end
    
    
    def refresh_keys
      raise "Attempted to update keys when unable to authenticate credentials with github" if @status != :authenticated
      
      path = '/user/keys'
      
      http = Net::HTTP.new(@server,443)
      req = Net::HTTP::Get.new(path)
      http.use_ssl = true
      req.basic_auth @account_name, @password
      response = http.request(req)
      
      # TODO: If body contains no keys or some kind of error, return nil???  I gotta learn the API more
      
      @keys = JSON.parse(response.body)
    end
    
    
    # Cycles through github, looking to see if rsa exists as a public key, then deletes it if it does
    def remove_key!(rsa)
      refresh_keys
      
      # loop through arrays checking against 'key'
      @keys.each do |key|
        if key["key"] == rsa
          return remove_key_by_id!(key["id"])
        end
      end
      
      return false   # key not found      
    end
    
    
    private
      def authenticate
        path = '/user'
        
        http = Net::HTTP.new(@server,443)
        http.use_ssl = true
        
        req = Net::HTTP::Get.new(path)
        req.basic_auth @account_name, @password
        response = http.request(req)
        
        result = JSON.parse(response.body)["message"]
        
        if result == "Bad credentials"
          @status = :bad_credentials
          return false
        else
          @status = :authenticated
          return true
        end
      end
      
      def get_username_and_password_and_authenticate
        puts "Type your github.com user name:"
        print "User: "
        account_name = STDIN.gets.strip
        
        puts "Type your github password:"
        password = ask("Password: ") { |q| q.echo = false }
        puts
        
        credentials = {:account_name => account_name, :password => password}
        #p credentials
        @account_name = account_name
        @password = password
          
        if authenticate
          return credentials
        else
          return false
        end
      end
      
      # Get's the username and password from the user, then authenticates.  If it fails, it asks them if they'd like to try again.  
      # Returns false if aborted
      def get_username_and_password_diligently
        while true
          credentials = get_username_and_password_and_authenticate
          if credentials == false
            puts "Could not authenticate, try again?"
            puts "y/n"
            
            again = STDIN.gets.strip
            case again.downcase
            when "y"
            when "n"
              return false
            end
          else
            return credentials
          end
        end
      end
      
      def install_key(rsa)
        require "socket"
        host_name = Socket.gethostname
        
        title = "GAS: #{@user.nickname} \-#{host_name}"
        
        path = '/user/keys'
        
        http = Net::HTTP.new(@server, 443)   # 443 for ssl
        http.use_ssl = true
        
        req = Net::HTTP::Post.new(path)
        req.basic_auth @account_name, @password
        req.body = "{\"title\":\"#{title}\", \"key\":\"#{rsa}\"}"
        
        response = http.start {|m_http| m_http.request(req) }
        the_code = response.code
        
        key_json = JSON.parse(response.body)
        
        return key_json if the_code == "201"
                
        puts "The key you are trying to use already exists in another github user's account.  You need to use another key." if the_code == "already_exists"
        
        # currently.. I think it always returns "already_exists" even if successful.  API bug.  
        puts "Something may have gone wrong.  Either github changed their API, or your key couldn't be installed." if the_code != "already_exists"
        
        #return true if my_hash.key?("errors")   # this doesn't work due to it being a buggy API atm  # false  change me to false when they fix their API
        puts "Server Response: #{response.body}"
        return false
      end
      
      # Cycles through github, looking to see if rsa exists as a public key, then deletes it if it does
      def has_key(rsa)
        refresh_keys if @keys.nil?
        return false if @keys.empty?
        
        # loop through arrays checking against 'key'
        @keys.each do |key|
          return true if key["key"] == rsa
        end
  
        return false   # key not found      
      end
      
      def remove_key_by_id!(id)
        path = "/user/keys/#{id}"
        
        http = Net::HTTP.new(@server,443)
        http.use_ssl = true
        req = Net::HTTP::Delete.new(path)
        req.basic_auth @account_name, @password
        
        response = http.request(req)
        
        if response.body.nil?
          # TODO:  remove the key from the keys attribute
          @keys = nil  # lame hack! sooo lazy of me.  I should learn how to remove the proper key from the @keys hash...
          # @keys.delete()
          
          return true
        end
      end
    
  end
end