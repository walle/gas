module Gas
  
  # This is for checking if a .gas/rsa file already exists for a nickname which is being registered
  # If the rsa exists, then we're goona need to ask if we should use it, or if we should delete it
  #
  # Returns true to indicate that the user would like to use the rsa file already in .gas ()  
  # Returns false when there is no naming conflicts.
  #
  # TODO should report an error if there is a write protection problem which prevents gas from deleting the file, or 
  # at least warn the user that there bidding could not be carried out.  
  def id_rsa_already_in_gas_dir?
    if corresponding_rsa_files_exist?
      puts "Gas has detected a key in its archive directory ~/.gas/#{nickname}_id_rsa.  Should gas use this key or overwrite this key with a brand new one?"
      puts "Keep current key? [y/n]"
      keep_current_file = gets
          
      if keep_current_file == "y"
        return true # keep the files already in .gas, skip making key.  
      end
    
    else # no need to do anything if files don't exist
      return false 
    end
  end
  
  
  def corresponding_rsa_files_exist?
    return true if exists? "#{@nickname}_id_rsa" && exists? "#{@nickname}_id_rsa.pub"
    false
  end
  
  
  def gas_dir_exists?
    gas_dir = Dir::pwd + "/" + ".gas"
    
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
  def check_uniqueness_of_rsa
    #  TODO
    
    #  loop through each NICKNAME_id_rsa file in ~/.gas/ and make sure it isn't identical to any of the others
    #  If it is identical...  Alert the user and ask them if they're sure they want to use id
    
    return true
  end
  
  
  def use_current_rsa_files_for_this_user
    gas_dir_exists?  # create if it doesn't
    
    return false if check_uniqueness_of_rsa  # TODO, this would return if the
    
    cmd_result = `cp ~/.ssh/id_rsa ~/.gas/#{@nickname}_id_rsa`
    cmd_result = `cp ~/.ssh/id_rsa.pub ~/.gas/#{@nickname}_id_rsa.pub`
  end
  
  
  #  Checks if the ~/.ssh directroy contains id_rsa and id_rsa.pub
  #  if it does, it asks the user if they would like to use that as their ssh key, instead of generating a new key pair.  
  #  
  def id_rsa_already_in_ssh_directory?
    puts "Gas has detected that an ~/.ssh/id_rsa file already exists.  Would you like to use this as your ssh key to connect with github?  Otherwise a new key will be generated and stored in ~/.gas (no overwrite concerns until you 'gas use nickname')"
      puts "[y/n]"
      
      while true
        use_current_rsa_files = gets
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
  
  
  #  
  def generate_new_rsa_keys_in_gas_dir
    #
    # Generate sshkey
    puts "Generating new ssh key..."
    
    puts `ssh-keygen -f ~/.gas/id_rsa -t rsa -C "INSERT@EMAIL.COM" -N ""`
    # 
    #  
  end
  
  
  # This function creates the ssh keys if needed and puts them in ~/.gas/NICKNAME_id_rsa and ...rsa.pub
  # 
  # 
  def setup_ssh_keys
  
  # TODO ##################################################
    #  Notes:  Check and see if i need to "require" ssh-keygen or something like that.  
    #
    # 1)  Prompt user if they would like gas to juggle SSH keys for them
    #       <Assume yes>
    #
    puts "Do you want gas to handle switching rsa keys for this user?"
    puts "[y/n]"
    handle_rsa = gets
    
    if handle_rsa == "y"
      
      return true if id_rsa_already_in_gas_dir? # No more work needs to be done if the files already exists
      
      #  Check ~/.ssh for a current id_rsa file, if yes, "Do you want to use the current id_rsa file to be used as your key?"
      
      return true if id_rsa_already_in_ssh_directory?  # copies the keys instead of generating new keys if desired/possible
      
      generate_new_rsa_keys_in_gas_dir
      
    
      
    
    else if handle_rsa == "n"
      # check if ~/.gas/rsa exists, if it does, promt the user
      if corresponding_rsa_files_exist? #in ~/.gas/
        
        puts "Well... there's already a ~/.gas/#{@nickname}_id_rsa configured and ready to go.  Are you sure you don't want gas to handle rsa switching?  (Clicking no will delete the key from the gas directory)"
        puts "Just let gas handle ssh key for this user? [y/n]"
        keep_file = gets
        
        if keep_file == "n"
          delete "~/.gas/#{@nickname}_id_rsa", "~/.gas/#{@nickname}_id_rsa.pub"
        end
      end
    end
    
    
     
  
  end
        