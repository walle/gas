module Gas
  class Ssh
    require 'highline/import'
    require 'net/https'
    require 'json'
    require 'digest/md5'
    extend Prompter

    def self.corresponding_rsa_files_exist?(nickname = '')
      nickname = @uid if nickname  == ''
      return true if File.exists? "#{GAS_DIRECTORY}/#{nickname}_id_rsa" and File.exists? "#{GAS_DIRECTORY}/#{nickname}_id_rsa.pub"
      false
    end

    # Copies a key pair from ~/.ssh to .gas/Nickname*
    def self.use_current_rsa_files_for_this_user(test = nil)
      @uid = test unless test.nil?
      FileUtils.cp("#{SSH_DIRECTORY}/id_rsa", "#{GAS_DIRECTORY}/#{@uid}_id_rsa")
      FileUtils.cp("#{SSH_DIRECTORY}/id_rsa.pub", "#{GAS_DIRECTORY}/#{@uid}_id_rsa.pub")
      FileUtils.chmod 0700, "#{GAS_DIRECTORY}/#{@uid}_id_rsa"
      FileUtils.chmod 0700, "#{GAS_DIRECTORY}/#{@uid}_id_rsa.pub"
      return true
    end

    def self.ssh_dir_contains_rsa?
      return true if File.exists?(SSH_DIRECTORY + "/id_rsa") or File.exists?(SSH_DIRECTORY + "/id_rsa.pub")
      return false
    end

    # Generates a new sshkey putting it in ~/.gas/nickname_id_rsa
    # This function can get a little tricky.  It's best to strip off the comment here,
    # because github API doesn't retain the comment...
    def self.generate_new_rsa_keys_in_gas_dir
      puts "Generating new ssh key..."

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

    # This function creates the ssh keys if needed and puts them in ~/.gas/NICKNAME_id_rsa and ...rsa.pub
    def self.setup_ssh_keys(user)
      @uid = user.nickname
      @email = user.email

      if Gas::Prompter.user_wants_gas_to_handle_rsa_keys?
        if corresponding_rsa_files_exist?(@uid) and Gas::Prompter.user_wants_to_use_key_already_in_gas?(@uid)
          return true  # We don't need to do anything because the .gas directory is already setup
        elsif !corresponding_rsa_files_exist?(@uid) and ssh_dir_contains_rsa? and Gas::Prompter.user_wants_to_use_key_already_in_ssh?   #  Check ~/.ssh for a current id_rsa file, if yes, "Do you want to use the current id_rsa file to be used as your key?"
          use_current_rsa_files_for_this_user    # copies the keys from ~/.ssh instead of generating new keys if desired/possible
          return true
        else
          return generate_new_rsa_keys_in_gas_dir
        end

      else # !Gas::Prompter.user_wants_gas_to_handle_rsa_keys?
        # check if ~/.gas/rsa exists, if it does, promt the user
        # because that key must be destroyed (if the user really doesn't want gas handling keys for this user)
        if corresponding_rsa_files_exist?(@uid) #in ~/.gas/
          delete_associated_local_keys!(@uid) if Gas::Prompter.user_wants_to_remove_the_keys_that_already_exist_for_this_user?(@uid)
        end
      end

    end

    # This huge method handles the swapping of id_rsa files on the hdd
    def self.swap_in_rsa(nickname)
      @uid = nickname  # woah, this is extremely sloppy I think... in order to use any other class methods,
                       #  I need to write to @uid or it will
                       #  Have the dumb information from the last time it registered a new git author?

      if corresponding_rsa_files_exist?
        if ssh_dir_contains_rsa?
          if current_key_already_backed_up?
            write_to_ssh_dir!
          else
            if Gas::Prompter.user_wants_to_overwrite_existing_rsa_key?
              write_to_ssh_dir!
            else
              puts "Proceeding without swapping rsa keys (aborting)."
            end
          end
        else # if no ~/.ssh/id_rsa exists... no overwrite potential... so just write away
          write_to_ssh_dir!
        end
      end
    end

    
    def self.write_to_ssh_dir!
      supress_process_output = "> /dev/null 2>&1"
      supress_process_output = "> NUL" if IS_WINDOWS

      # remove the current key from the ssh-agent session (key will no longer be used with github)
      system("ssh-add -d #{SSH_DIRECTORY}/id_rsa #{supress_process_output}") if is_ssh_agent_there?

      FileUtils.cp(GAS_DIRECTORY + "/#{@uid}_id_rsa", SSH_DIRECTORY + "/id_rsa")
      FileUtils.cp(GAS_DIRECTORY + "/#{@uid}_id_rsa.pub", SSH_DIRECTORY + "/id_rsa.pub")

      FileUtils.chmod(0700, SSH_DIRECTORY + "/id_rsa")
      FileUtils.chmod(0700, SSH_DIRECTORY + "/id_rsa.pub")

      if is_ssh_agent_there?
        `ssh-add #{SSH_DIRECTORY}/id_rsa #{supress_process_output}`  # you need to run this command to get the private key to be set to active on unix based machines.  Not sure what to do for windows yet...

        if $?.exitstatus == 1    # exit status 1 means failed
          puts "Looks like there may have been a fatal error in registering the rsa key with ssh-agent.  Might be worth looking into"
          raise "Exit code on ssh-add command line was one meaning: Error!"
        end

      else
        puts "Slight Error:  The key should now be in ~/.ssh so that's good, BUT ssh-add could not be found.  If you're using windows, you'll need to use git bash or cygwin to emulate this unix command and actually do uploads."
      end
      
    end

    # This function scans each file in a directory to check 
    # to see if it is the same file which it's being compared against
    # dir_to_scan        The target directory you'd like to scan
    # file_to_compare    The file's path that you're expecting to find
    def self.scan_for_file_match(file_to_compare, dir_to_scan)
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
        file = File.open(file_path, "rb")
        hash = Digest::MD5.hexdigest(file.read)
        file.close
        return hash
      end
      return nil
    end


    def self.upload_public_key_to_github(user, github_speaker = nil)
      if Gas::Prompter.user_wants_to_install_key_to_github?
        key_installation_routine!(user, nil, github_speaker)
      end
    end

    
    def self.key_installation_routine!(user = nil, rsa_test = nil, github_speaker = nil)
      @uid = user.nickname unless user.nil?      # allows for easy testing

      rsa_key = get_associated_rsa_key(@uid).first
      rsa_key = rsa_test unless rsa_test.nil?
      return false if rsa_key.nil?

      #  TODO:  Impliment a key ring system where you store your key on your github in a repository, only it's encrypted.  And to decrypt it, there is
      #    A file in your .gas folder!!!  That sounds SO fun!
      github_speaker = GithubSpeaker.new(user) if github_speaker.nil?
      
      puts github_speaker.status

      if github_speaker.status == :bad_credentials
        puts "Invalid credentials.  Skipping upload of keys to github.  "
        puts "To try again, type  $  gas ssh #{@uid}"
        return false
      end
      
      result = github_speaker.post_key!(rsa_key)
      
      if result
        puts "Key uploaded successfully!"
        return true
      end
    end

    # Get's the ~/.gas/user_id_rsa and ~/.gas/user_id_rsa.pub strings associated with 
    # the specified user and returns it as an array.  Returns array with two nils if there's no keys
    # [pub_rsa, priv_rsa]
    def self.get_associated_rsa_key(nickname)
      pub_path = "#{GAS_DIRECTORY}/#{nickname}_id_rsa.pub"
      priv_path = "#{GAS_DIRECTORY}/#{nickname}_id_rsa"

      if File.exists? pub_path and File.exists? priv_path
        pub_file = File.open(pub_path, "rb")
        pub_rsa = pub_file.read.strip
        pub_file.close
        if pub_rsa.count(' ') == 2             # special trick to split off the trailing comment text because github API won't store it.
          pub_rsa = pub_rsa.split(" ")
          pub_rsa = "#{rsa[0]} #{rsa[1]}"
        end
        
        priv_file = File.open(priv_path, "rb")
        priv_rsa = priv_file.read.strip
        priv_file.close

        return [pub_rsa, priv_rsa]
      end
      return [nil, nil]
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

      case Gas::Prompter.user_wants_to_delete_all_ssh_data?
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
      return false if get_associated_rsa_key(nickname).first.nil?
      return true
    end

    def self.delete_associated_github_keys!(nickname)
      rsa = get_associated_rsa_key(nickname).first
      
      credentials = get_nils
      
      github_speaker = GithubSpeaker.new(nickname, credentials[:username], credentials[:password])
      
      result = github_speaker.remove_key! rsa
      puts "The key for this user was not in the specified github account's public keys section." if !result
    end
    
    # this is just for testing... it gets stubbed... otherwise, the nils are normal and allow for
    # normal prompting for username and password from within the GithubSpeaker class
    def self.get_nils; { :username => nil, :password => nil };end

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
    
  end
end