module Gas
  
  class Ssh
    
    
    
    # This is for checking if a .gas/rsa file already exists for a nickname which is being registered
    # If the rsa exists, then we're goona need to ask if we should use it, or if we should delete it
    #
    # Returns true to indicate that the user would like to use the rsa file already in .gas ()  
    # Returns false when there is no naming conflicts.
    #
    # TODO should report an error if there is a write protection problem which prevents gas from deleting the file, or 
    # at least warn the user that there bidding could not be carried out.  
    def self.id_rsa_already_in_gas_dir?
      if corresponding_rsa_files_exist?
        puts "Gas has detected a key in its archive directory ~/.gas/#{@uid}_id_rsa.  Should gas use this key or overwrite this key with a brand new one?"
        puts "Keep current key? [y/n]"
        keep_current_file = STDIN.gets
            
        if keep_current_file == "y"
          return true # keep the files already in .gas, skip making key.  
        end
      
      else # no need to do anything if files don't exist
        return false 
      end
    end
    
    
    def self.corresponding_rsa_files_exist?
      return true if File.exists? "#{GAS_DIRECTORY}/#{@uid}_id_rsa" and File.exists? "#{GAS_DIRECTORY}/#{@uid}_id_rsa.pub"   # TODO: Unit test me
      false
    end
    
    
    def self.gas_dir_exists?
      gas_dir = Dir::pwd + "/" + ".gas"
      
      return "this function not needed... I think"
      
      return if FileTest::directory?(directory_name)
      begin
        Dir::mkdir(directory_name)
      rescue
        puts "Failed to create .gas directory!  SSH keys juggling can't work without this!"
        # TODO do something to terminate the process or something?
      end
      
    end
    
    #   Check if id_rsa is a clone of another stored id_rsa and prompt user to make sure they're aware
    #   and want to proceed anyway, or if they'd like to generate a new id_rsa
    #   TODO:  returns false if the id_rsa file isn't unique and the user changes his mind and wants a new key
    #     generated
    #
    def self.rsa_unique?
      #  TODO
      
      #  loop through each NICKNAME_id_rsa file in ~/.gas/ and make sure it isn't identical to any of the others
      #  If it is identical...  Alert the user and ask them if they're sure they want to use id
      
      return true
    end
    
    
    def self.use_current_rsa_files_for_this_user
      gas_dir_exists?  # create if it doesn't
      
      return false if !rsa_unique?  # this would return false if it found out that key was already in use for another git author... but what if the user wants this...
      
      cmd_result = `cp ~/.ssh/id_rsa ~/.gas/#{@uid}_id_rsa`           # TODO: make this into ruby code so its faster I guess?
      cmd_result = `cp ~/.ssh/id_rsa.pub ~/.gas/#{@uid}_id_rsa.pub`   # TODO: Handle permission errors
      return true
    end
    
    
    def self.ssh_dir_contains_rsa?
      return true if File.exists?(SSH_DIRECTORY + "/id_rsa") or File.exists?(SSH_DIRECTORY + "/id_rsa.pub")
      return false
    end
    
    #  Checks if the ~/.ssh directroy contains id_rsa and id_rsa.pub
    #  if it does, it asks the user if they would like to use that as their ssh key, instead of generating a new key pair.  
    #  
    def self.id_rsa_already_in_ssh_directory?
      return false unless ssh_dir_contains_rsa?
      
      
      puts "Gas has detected that an ~/.ssh/id_rsa file already exists.  Would you like to use this as your ssh key to connect with github?  Otherwise a new key will be generated and stored in ~/.gas (no overwrite concerns until you 'gas use nickname')"
      puts "[y/n]"
      
      while true
        use_current_rsa_files = STDIN.gets.strip
        case use_current_rsa_files
          when "y"
            if use_current_rsa_files_for_this_user
              return true # return true if 
            else
              return false
            end
          when "n"
            return false
          else
            puts "plz answer 'y' or 'n'"
        end
      end
    end
    
    
    # Generates a new sshkey putting it in ~/.gas/nickname_id_rsa
    def self.generate_new_rsa_keys_in_gas_dir
      puts "Generating new ssh key..."
      # TODO: Prompt user if they'd like to use a more secure password if physical security to their computer is not possible (dumb imo)
      
      puts `ssh-keygen -f ~/.gas/#{@uid}_id_rsa -t rsa -C "#{@email}" -N ""`
    end
    
    
    # This function creates the ssh keys if needed and puts them in ~/.gas/NICKNAME_id_rsa and ...rsa.pub
    # 
    # 
    def self.setup_ssh_keys(user)
      @uid = user.nickname                 # TODO: question:  are nicknames allowed to be nil?  If not, this coding can be reduced to one line of code
      @uid = user.name if @uid.nil?
      
      @email = user.email
    # TODO ##################################################
      #  Notes:  Check and see if i need to "require" ssh-keygen or something like that.  
      #
      # 1)  Prompt user if they would like gas to juggle SSH keys for them
      #       <Assume yes>
      #
      puts "Do you want gas to handle switching rsa keys for this user?"
      puts "[y/n]"
      
      while true
        handle_rsa = STDIN.gets.strip
        
        case handle_rsa
        when "y"
          puts
          return true if id_rsa_already_in_gas_dir? # No more work needs to be done if the files already exists
          
          #  Check ~/.ssh for a current id_rsa file, if yes, "Do you want to use the current id_rsa file to be used as your key?"
          return true if id_rsa_already_in_ssh_directory?  # copies the keys instead of generating new keys if desired/possible
          
          return generate_new_rsa_keys_in_gas_dir
          
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
                delete "~/.gas/#{@uid}_id_rsa", "~/.gas/#{@uid}_id_rsa.pub"    # TODO:  Test me
                return false
              when "y"
                puts "Excelent!  Gas will handle rsa keys for this user."
                return true
              else
                puts "Please use 'y' or 'n'"
              end
            end
            
          end
        else
          puts "Please use 'y' or 'n'"
        end
      end
    
    end
    
    def self.user_has_ssh?
      #i todo f File.exists? @gitconfig...sleepy =(
      #  TODO: what's the best way to get @gitconfig into this method?
      if File.exists? "/bluemoon"
        return true
      end
      return false
    end
    
    # This huge method handles the swapping of id_rsa files
    # 
    def self.swap_in_rsa(nickname)
      @uid = nickname  # woah, this is extremely sloppy I think... in order to use any other class methods, 
                       #  I need to write to @uid or it will
                       #  Have the dumb information from the last time it registered a new git author?
      
      if Ssh.corresponding_rsa_files_exist?
        
        if ssh_dir_contains_rsa?
          # TODO: File compare if the file in ~/.ssh is the same one as ~/.gas/nick, and if it is, there's no need for prompt
          # TODO: File compare to see if the file in ~/.ssh is already backed up in ~/.gas/ and if it is, no need for prompt
          # 
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
      `cp ~/.gas/#{@uid}_id_rsa ~/.ssh/id_rsa`
      `cp ~/.gas/#{@uid}_id_rsa.pub ~/.ssh/id_rsa.pub`
    end
    
    # This function scans each file in a directory to check to see if it is the same file which it's being compared against
    # dir_to_scan        The target directory you'd like to scan
    # file_to_compare    The file's path that you're expecting to find 
    def self.scan_for_file_match(file_to_compare, dir_to_scan)
      # TODO:  Make this
      require 'digest/md5'
      
      pattern = get_md5_hash(file_to_compare)
      
      @files = Dir.glob(dir_to_scan + "/*" + file_to_compare.split(//).last(1).to_s)
      
      @files.each do |file|                              # TODO: optimize to filter with and without .pub accordingly
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
      return Digest::MD5.hexdigest(File.open(file_path, "rb").read)
    end
  end
  
end

