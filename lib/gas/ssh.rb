module Gas

  class Ssh
    require 'highline/import'
    require 'net/https'
    require 'json'
    require 'gas/GithubSpeaker'


    # If the user says 'f', the system will
    #   report that there isn't an id_rsa already in gas.  This causes a new key to overwrite automatically down the road.
    # This is for checking if a .gas/rsa file already exists for a nickname which is being registered
    # If the rsa exists, then we're goona need to ask if we should use it, or if we should delete it
    #
    # Returns true to indicate that the user would like to use the rsa file already in .gas ()
    # Returns false when there is no naming conflicts.
    def self.user_wants_to_use_key_already_in_gas?
      if corresponding_rsa_files_exist?
        puts "Gas has detected a key in its archive directory ~/.gas/#{@uid}_id_rsa.  Should gas use this key or overwrite this key with a brand new one?"
        puts "Keep current key? [y/n]"

        while true
          keep_current_file = STDIN.gets.strip

          case keep_current_file

          when "y"
            return true # keep the files already in .gas, skip making key.
          when "n"
            return false
          else
            puts "please respond 'y' or 'n'"
          end
        end

      else # no need to do anything if files don't exist
        return false
      end
    end


    def self.corresponding_rsa_files_exist?(nickname = '')
      nickname = @uid if nickname  == ''
      return true if File.exists? "#{GAS_DIRECTORY}/#{nickname}_id_rsa" and File.exists? "#{GAS_DIRECTORY}/#{nickname}_id_rsa.pub"
      false
    end


    # Copies a key pair from ~/.ssh to .gas/Nickname*
    def self.use_current_rsa_files_for_this_user(test = nil)
      @uid = test unless test.nil?
      cmd_result = `cp ~/.ssh/id_rsa ~/.gas/#{@uid}_id_rsa`
      cmd_result = `cp ~/.ssh/id_rsa.pub ~/.gas/#{@uid}_id_rsa.pub`
      return true
    end


    def self.ssh_dir_contains_rsa?
      return true if File.exists?(SSH_DIRECTORY + "/id_rsa") or File.exists?(SSH_DIRECTORY + "/id_rsa.pub")
      return false
    end



    #  Checks if the ~/.ssh directroy contains id_rsa and id_rsa.pub
    #  if it does, it asks the user if they would like to use that as their ssh key, instead of generating a new key pair.
    #
    def self.user_wants_to_use_key_already_in_ssh?
      return false unless ssh_dir_contains_rsa?

      #puts "Gas has detected that an ~/.ssh/id_rsa file already exists.  Would you like to use this as your ssh key to connect with github?  Otherwise a new key will be generated and stored in ~/.gas (no overwrite concerns until you 'gas use nickname')"
      puts "Generate a brand new ssh key pair?  (Choose 'n' to use key in ~/.ssh/id_rsa)"
      puts "Default: 'y'"
      puts "[Y/n]"

      while true
        generate_new_rsa = STDIN.gets.strip.downcase
        case generate_new_rsa
          when "y", ""
            return false
          when "n"
            return true # return true if we aren't generating a new key
          else
            puts "plz answer 'y' or 'n'"
        end
      end
    end



    # Generates a new sshkey putting it in ~/.gas/nickname_id_rsa
    # This function can get a little tricky.  It's best to strip off the comment here,
    # because github API doesn't retain the comment...
    def self.generate_new_rsa_keys_in_gas_dir
      puts "Generating new ssh key..."
      # TODO: Prompt user if they'd like to use a more secure password if physical security to their computer is not possible (dumb imo)... Unless we do that thing where we store keys on github!

      # Old ssh key method (relies on unix environment)
      # puts `ssh-keygen -f ~/.gas/#{@uid}_id_rsa -t rsa -C "#{@email}" -N ""`    # ssh-keygen style key creation

      # new sshkey gem method...
      begin
        k = SSHKey.generate()         #   (:comment => "#{@email}")

        publ = k.ssh_public_key
        privl = k.private_key

        my_file_privl = File.open(GAS_DIRECTORY + "/#{@uid}_id_rsa",'w',0700)
        my_file_privl.write(privl)
        my_file_privl.close

        my_file_publ = File.open(GAS_DIRECTORY + "/#{@uid}_id_rsa.pub",'w',0700)
        my_file_publ.write(publ)
        my_file_publ.close

        return true
      rescue
        puts "Fatal Error:  Something unexpected happened while writing to #{GAS_DIRECTORY}/#{@uid}_id_rsa"
        puts "SSH key not saved."
        return false
      end
    end



    def self.user_wants_gas_to_handle_rsa_keys?
      puts "Do you want gas to handle switching rsa keys for this user?"
      puts "[Y/n]"

      while true
        handle_rsa = STDIN.gets.strip

        case handle_rsa
        when "y", ""
          return true
        when "n"
          puts
          # check if ~/.gas/rsa exists, if it does, promt the user
          if corresponding_rsa_files_exist? #in ~/.gas/

            puts "Well... there's already a ~/.gas/#{@uid}_id_rsa configured and ready to go.  Are you sure you don't want gas to handle rsa switching?  (Clicking no will delete the key from the gas directory)"
            puts "Just let gas handle ssh key for this user? [y/n]"

            while true
              keep_file = STDIN.gets.strip

              case keep_file
              when "n"
                delete "~/.gas/#{@uid}_id_rsa", "~/.gas/#{@uid}_id_rsa.pub"
                return false
              when "y"
                puts "Excelent!  Gas will handle rsa keys for this user."
                return nil
              else
                puts "Please use 'y' or 'n' or enter to choose default."
              end
            end
          end
          return false

        else
          puts "Please use 'y' or 'n'"
        end
      end


    end

    # This function creates the ssh keys if needed and puts them in ~/.gas/NICKNAME_id_rsa and ...rsa.pub
    #
    #
    def self.setup_ssh_keys(user)
      @uid = user.nickname
      @email = user.email

      wants_gas_handling_keys = user_wants_gas_to_handle_rsa_keys?

      if wants_gas_handling_keys
        puts

        if user_wants_to_use_key_already_in_gas?
          return true  # We don't need to do anything because the .gas directory is already setup
        elsif user_wants_to_use_key_already_in_ssh?   #  Check ~/.ssh for a current id_rsa file, if yes, "Do you want to use the current id_rsa file to be used as your key?"
          use_current_rsa_files_for_this_user    # copies the keys from ~/.ssh instead of generating new keys if desired/possible
          return true
        else
          return generate_new_rsa_keys_in_gas_dir
        end

      elsif wants_gas_handling_keys.nil?
        return true  # if user_wants_gas_to_handle_rsa_keys? returns nill that means the user actually had ssh keys already in .gas, and they would like to use those.
      else
        return false # if user doesn't want gas to use ssh keys, that's fine too.
      end

    end


    # This huge method handles the swapping of id_rsa files on the hdd
    #
    def self.swap_in_rsa(nickname)
      @uid = nickname  # woah, this is extremely sloppy I think... in order to use any other class methods,
                       #  I need to write to @uid or it will
                       #  Have the dumb information from the last time it registered a new git author?

      if Ssh.corresponding_rsa_files_exist?

        if ssh_dir_contains_rsa?
          if current_key_already_backed_up?
            write_to_ssh_dir!
          else
            puts "~/.ssh/id_rsa already exists.  Overwrite?"
            puts "[y/n]"

            while true
              overwrite = STDIN.gets.strip
              case overwrite
                when "y"
                  write_to_ssh_dir!
                  break
                when "n"
                  puts "Proceeding without swapping rsa keys."
                  break
                else
                  puts "please respond 'y' or 'n'"
              end
            end

          end

        else # if no ~/.ssh/id_rsa exists... no overwrite potential
          write_to_ssh_dir!
        end

      end
    end


    def self.write_to_ssh_dir!
      # remove the current key from the ssh-agent session (key will no longer be used with github)
      system('ssh-add -d ~/.ssh/id_rsa > /dev/null 2>&1') if is_ssh_agent_there?

      FileUtils.cp(GAS_DIRECTORY + "/#{@uid}_id_rsa", SSH_DIRECTORY + "/id_rsa")
      FileUtils.cp(GAS_DIRECTORY + "/#{@uid}_id_rsa.pub", SSH_DIRECTORY + "/id_rsa.pub")

      FileUtils.chmod(0700, SSH_DIRECTORY + "/id_rsa")
      FileUtils.chmod(0700, SSH_DIRECTORY + "/id_rsa.pub")

      if is_ssh_agent_there?
        `ssh-add ~/.ssh/id_rsa > /dev/null 2>&1`  # you need to run this command to get the private key to be set to active on unix based machines.  Not sure what to do for windows yet...
        
        if $?.exitstatus == 1    # exit status 1 means failed
          puts "Looks like there may have been a fatal error in registering the rsa key with ssh-agent.  Might be worth looking into"
          raise "Exit code on ssh-add command line was one meaning: Error!"
        end
        
        # Possible bug fix solution to using gas not in the local GUI environment:  (delete me in a while if things are running stable, plz -- 10-22-2011)
        #
        #if $?.exitstatus == 2    # exit 2 means it couldn't contact the ssh agent... happens over ssh on root...
          # There seems to be no problem with the command exiting with status 2... although if people are having problems using this with
          # ssh, then this is the first place I'd look to solve it.  Maybe create a new bash with ssh-agent running in it
          # and then attempt the ssh-add command and it should return 0 just fine
          # puts "Exit status 2 detected...  You must be using ssh.  I don't think it will matter..."
        #end
        

      else
        puts "Slight Error:  The key should now be in ~/.ssh so that's good, BUT ssh-add could not be found.  If you're using windows, you'll need to use git bash or cygwin to emulate this unix command and actually do uploads."
      end
      
    end


    # This function scans each file in a directory to check to see if it is the same file which it's being compared against
    # dir_to_scan        The target directory you'd like to scan
    # file_to_compare    The file's path that you're expecting to find
    def self.scan_for_file_match(file_to_compare, dir_to_scan)
      require 'digest/md5'

      pattern = get_md5_hash(file_to_compare)

      @files = Dir.glob(dir_to_scan + "/*" + file_to_compare.split(//).last(1).to_s)

      @files.each do |file|
        return true if get_md5_hash(file) == pattern
      end

      return false
    end


    def self.current_key_already_backed_up?
      if scan_for_file_match(SSH_DIRECTORY + "/id_rsa", GAS_DIRECTORY) and scan_for_file_match(SSH_DIRECTORY + "/id_rsa.pub", GAS_DIRECTORY)
        return true
      else
        return false
      end
    end

    def self.get_md5_hash(file_path)
      if File.exists? file_path
        return Digest::MD5.hexdigest(File.open(file_path, "rb").read)
      end
      return nil
    end


    def self.user_wants_to_install_key_to_github?
      puts "Gas can automatically install this ssh key into the github account of your choice.  Would you like gas to do this for you?  (Requires inputting github username and password)"
      puts "[Y/n]"

      while true
        upload_key = STDIN.gets.strip.downcase
        case upload_key
        when "y", ""
          return true
        when "n"
          return false
        else
          puts "Plz respond 'y' or 'n'"
        end
      end
    end


    def self.upload_public_key_to_github(user)

      if user_wants_to_install_key_to_github?
        key_installation_routine!(user)
      end
    end

    
    def self.key_installation_routine_oo!(user = nil, rsa_test = nil)
      @uid = user.nickname unless user.nil?      # allows for easy testing

      rsa_key = get_associated_rsa_key(@uid)
      rsa_key = rsa_test unless rsa_test.nil?
      return false if rsa_key.nil?

      #  TODO:  Impliment a key ring system where you store your key on your github in a repository, only it's encrypted.  And to decrypt it, there is
      #    A file in your .gas folder!!!  That sounds SO fun!
      gs = GithubSpeaker.new(user)
      
      puts gs.status
      

      if gs.status == :bad_credentials
        puts "Invalid credentials.  Skipping upload of keys to github.  "
        puts "To try again, type  $  gas ssh #{@uid}"
        return false
      end
      
      result = gs.post_key!(rsa_key)
      
      if result
        puts "Key uploaded successfully!"
        return true
      end
    end
    

    def self.key_installation_routine!(user = nil, rsa_test = nil)
      @uid = user.nickname unless user.nil?      # allows for easy testing

      rsa_key = get_associated_rsa_key(@uid)
      rsa_key = rsa_test unless rsa_test.nil?
      return false if rsa_key.nil?

      #  TODO:  Impliment a key ring system where you store your key on your github in a repository, only it's encrypted.  And to decrypt it, there is
      #    A file in your .gas folder!!!  That sounds SO fun!
      credentials = get_username_and_password_diligently

      if !credentials
        puts "Invalid credentials.  Skipping upload of keys to github.  "
        puts "To try again, type  $  gas ssh #{@uid}"
        return false
      end

      result = post_key!(credentials, @uid, rsa_key)
      if result
        puts "Key uploaded successfully!"
        return true
      end
    end


    # Get's the ~/.gas/user_id_rsa associated with the specified user and returns it as a string
    def self.get_associated_rsa_key(nickname)
      file_path = "#{GAS_DIRECTORY}/#{nickname}_id_rsa.pub"

      if File.exists? file_path
        rsa = File.open(file_path, "rb").read.strip
        if rsa.count(' ') == 2             # special trick to split off the trailing comment text because github API won't store it.
          rsa = rsa.split(" ")
          rsa = "#{rsa[0]} #{rsa[1]}"
        end

        return rsa
      end
      return nil
    end


    def self.get_username_and_password_and_authenticate
      puts "Type your github.com user name:"
      print "User: "
      username = STDIN.gets.strip

      puts "Type your github password:"
      password = ask("Password: ") { |q| q.echo = false }
      puts

      credentials = {:username => username, :password => password}

      if valid_github_username_and_pass?(credentials[:username], credentials[:password])
        return credentials
      else
        return false
      end
    end

    # Get's the username and password from the user, then authenticates.  If it fails, it asks them if they'd like to try again.
    # Returns false if aborted
    def self.get_username_and_password_diligently
      while true
        credentials = get_username_and_password_and_authenticate
        if !credentials
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


    def self.valid_github_username_and_pass?(username, password)
      path = '/user'

      http = Net::HTTP.new(GITHUB_SERVER,443)
      http.use_ssl = true

      req = Net::HTTP::Get.new(path)
      req.basic_auth username, password
      response = http.request(req)

      result = JSON.parse(response.body)["message"]

      return false if result == "Bad credentials"
      return true
    end


    def self.post_key!(credentials, nickname, rsa)
      puts "Posting key to GitHub.com..."
      rsa_key = rsa
      username = credentials[:username]
      password = credentials[:password]


      #  find key...
      if has_key(username, password, rsa_key)
        puts "Key already installed."
        return false
      end
      title = "GAS: #{nickname}"
      install_key(username, password, title, rsa_key)
    end


    def self.remove_key_by_id!(username, password, id)
      server = 'api.github.com'
      path = "/user/keys/#{id}"


      http = Net::HTTP.new(server,443)
      http.use_ssl = true
      req = Net::HTTP::Delete.new(path)
      req.basic_auth username, password

      response = http.request(req)

      return true if response.body.nil?
    end

    # Cycles through github, looking to see if rsa exists as a public key, then deletes it if it does
    def self.has_key(username, password, rsa)
      # get all keys
      keys = get_keys(username, password)
      # loop through arrays checking against 'key'
      keys.each do |key|
          if key["key"] == rsa
            return true
          end
      end

      return false   # key not found
    end


    # Cycles through github, looking to see if rsa exists as a public key, then deletes it if it does
    def self.remove_key!(username, password, rsa)
      # get all keys
      keys = get_keys(username, password)
      # loop through arrays checking against 'key'
      keys.each do |key|
          if key["key"] == rsa
            return remove_key_by_id!(username, password, key["id"])
          end
      end

      return false   # key not found
    end

    def self.get_keys(username, password)
      server = 'api.github.com'
      path = '/user/keys'


      http = Net::HTTP.new(server,443)
      req = Net::HTTP::Get.new(path)
      http.use_ssl = true
      req.basic_auth username, password
      response = http.request(req)

      return JSON.parse(response.body)
    end


    def self.install_key(username, password, title, rsa_key)
      server = 'api.github.com'
      path = '/user/keys'

      http = Net::HTTP.new(server, 443)   # 443 for ssl
      http.use_ssl = true

      req = Net::HTTP::Post.new(path)
      req.basic_auth username, password
      req.body = "{\"title\":\"#{title}\", \"key\":\"#{rsa_key}\"}"

      response = http.start {|http| http.request(req) }
      the_code = response.code

      keys_end = get_keys(username, password).length

      return true if the_code == "201"

      puts "The key you are trying to use already exists in another github user's account.  You need to use another key." if the_code == "already_exists"

      # currently.. I think it always returns "already_exists" even if successful.  API bug.
      puts "Something may have gone wrong.  Either github fixed their API, or your key couldn't be installed." if the_code != "already_exists"

      #return true if my_hash.key?("errors")   # this doesn't work due to it being a buggy API atm  # false  change me to false when they fix their API
      puts "Server Response: #{response.body}"
      return false
    end


    # Cross-platform way of finding an executable in the $PATH.
    # returns nil if command not present
    #
    #   which('ruby') #=> /usr/bin/ruby
    def self.which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each { |ext|
          exe = "#{path}/#{cmd}#{ext}"
          return exe if File.executable? exe
        }
      end
      return nil
    end

    def self.is_ssh_agent_there?
      return false if which("ssh-add").nil?
      return true
    end

    # deletes the ssh keys associated with a user
    def self.delete(nickname)
      return false unless user_has_ssh_keys?(nickname)  # return if no keys

      case user_wants_to_delete_all_ssh_data?
      when "a"
        delete_associated_github_keys!(nickname)
        delete_associated_local_keys!(nickname)
      when "l"
        delete_associated_local_keys!(nickname)
      when "g"
        delete_associated_github_keys!(nickname)
      when "n"
        return false
      end

    end

    def self.user_has_ssh_keys?(nickname)
      return false if get_associated_rsa_key(nickname).nil?
      return true
    end


    def self.delete_associated_github_keys!(nickname)
      rsa = get_associated_rsa_key(nickname)
      credentials = get_username_and_password_diligently
      if !credentials
        return false
      end
      result = remove_key!(credentials[:username], credentials[:password], rsa)
      puts "The key for this user was not in the specified github account's public keys section." if !result
    end


    def self.delete_associated_local_keys!(nickname)
      puts "Removing associated keys from local machine..."
      puts

      ssh_file = get_md5_hash("#{SSH_DIRECTORY}/id_rsa")
      gas_file = get_md5_hash("#{GAS_DIRECTORY}/#{nickname}_id_rsa")

      return false if gas_file.nil?       # if the gas file doesn't exist, return from this function safely, otherwise both objects could be nil, pass this check, and then fuck up our interpreter with file not found errors

      if ssh_file == gas_file
        File.delete("#{SSH_DIRECTORY}/id_rsa")
        File.delete("#{SSH_DIRECTORY}/id_rsa.pub")
      end

      File.delete("#{GAS_DIRECTORY}/#{nickname}_id_rsa")
      File.delete("#{GAS_DIRECTORY}/#{nickname}_id_rsa.pub")
    end

    # This is another prompt function, but it returns a more complicated lexicon
    #
    # returns "a", "l", "g", or "n"
    def self.user_wants_to_delete_all_ssh_data?
      puts "Would you like to remove all of this user's ssh keys too!?!"  
      puts "(github account keys can be removed as well!)"
      puts
      puts "a:  All, the local copy, and checks github too."
      puts "l:  Remove local key only."
      puts "g:  Removes key from github.com only."
      puts "n:  Don't remove this user's keys."
      puts "Default: l"

      while true
        delete_all_keys = STDIN.gets.strip

        case delete_all_keys.downcase
        when "a"
          return "a"
        when "l", ""
          return "l"
        when "g"
          return "g"
        when "n"
          return "n"
        else
          puts "please use 'a', 'l', 'g' or 'n' for NONE."
        end
      end
    end
    
  end
end


