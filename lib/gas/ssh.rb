module Gas
  
  class Ssh
    
    

    #  TODO: remove me, obsolete after "Impliment the below form..." refactor is complete
    def self.id_rsa_already_in_gas_dir_for_use?
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
    
    
    # If the user says 'f', the system will
    #   report that there isn't an id_rsa already in gas.  This causes a new key to overwrite automatically down the road.  
    # This is for checking if a .gas/rsa file already exists for a nickname which is being registered
    # If the rsa exists, then we're goona need to ask if we should use it, or if we should delete it
    #
    # Returns true to indicate that the user would like to use the rsa file already in .gas ()  
    # Returns false when there is no naming conflicts.
    #
    # TODO should report an error if there is a write protection problem which prevents gas from deleting the file, or 
    # at least warn the user that there bidding could not be carried out.  
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
    
    
    def self.corresponding_rsa_files_exist?
      return true if File.exists? "#{GAS_DIRECTORY}/#{@uid}_id_rsa" and File.exists? "#{GAS_DIRECTORY}/#{@uid}_id_rsa.pub"   # TODO: Unit test me
      false
    end
    
    
    def self.gas_dir_exists?        # TODO:  Wipe this function out, I don't think it's needed
      gas_dir = Dir::pwd + "/" + ".gas"
      
      return "this function not needed... I think"
      
      return if FileTest::directory?(directory_name)
      begin
        Dir::mkdir(directory_name)
      rescue
        puts "Failed to create .gas directory!  SSH keys juggling can't work without this!"
      end
      
    end
    
    # Copies a key pair from ~/.ssh to .gas/Nickname*
    # TODO: return false if a problem occured?  Also convert it to ruby code
    def self.use_current_rsa_files_for_this_user
      cmd_result = `cp ~/.ssh/id_rsa ~/.gas/#{@uid}_id_rsa`           # TODO: make this into ruby code so its faster I guess?
      cmd_result = `cp ~/.ssh/id_rsa.pub ~/.gas/#{@uid}_id_rsa.pub`   # TODO: Handle permission errors
      puts "This is for checking the test...  #{@uid}"
      return true
    end
    
    
    def self.ssh_dir_contains_rsa?
      return true if File.exists?(SSH_DIRECTORY + "/id_rsa") or File.exists?(SSH_DIRECTORY + "/id_rsa.pub")
      return false
    end
    
    #  Checks if the ~/.ssh directroy contains id_rsa and id_rsa.pub
    #  if it does, it asks the user if they would like to use that as their ssh key, instead of generating a new key pair.  
    #  
    #  TODO: remove me, obsolete after "Impliment the below form..." refactor is complete
    def self.id_rsa_already_in_ssh_directory?
      return false unless ssh_dir_contains_rsa?
      
      #puts "Gas has detected that an ~/.ssh/id_rsa file already exists.  Would you like to use this as your ssh key to connect with github?  Otherwise a new key will be generated and stored in ~/.gas (no overwrite concerns until you 'gas use nickname')"
      puts "Generate a brand new ssh key pair?"
      puts "[y/n]"
      
      while true
        generate_new_rsa = STDIN.gets.strip
        case generate_new_rsa
          when "y"
            return false
          when "n"
            return use_current_rsa_files_for_this_user # return true if we aren't generating a new key
          else
            puts "plz answer 'y' or 'n'"
        end
      end
    end
    
    #  Checks if the ~/.ssh directroy contains id_rsa and id_rsa.pub
    #  if it does, it asks the user if they would like to use that as their ssh key, instead of generating a new key pair.  
    #  
    def self.user_wants_to_use_key_already_in_ssh?
      return false unless ssh_dir_contains_rsa?
      
      #puts "Gas has detected that an ~/.ssh/id_rsa file already exists.  Would you like to use this as your ssh key to connect with github?  Otherwise a new key will be generated and stored in ~/.gas (no overwrite concerns until you 'gas use nickname')"
      puts "Generate a brand new ssh key pair?"
      puts "[y/n]"
      
      while true
        generate_new_rsa = STDIN.gets.strip
        case generate_new_rsa
          when "y"
            return false
          when "n"
            return true # return true if we aren't generating a new key
          else
            puts "plz answer 'y' or 'n'"
        end
      end
    end
    
    
    
    # Generates a new sshkey putting it in ~/.gas/nickname_id_rsa
    def self.generate_new_rsa_keys_in_gas_dir
      puts "Generating new ssh key..."
      # TODO: Prompt user if they'd like to use a more secure password if physical security to their computer is not possible (dumb imo)
      
      # Old ssh key method (relies on unix environment)
      # puts `ssh-keygen -f ~/.gas/#{@uid}_id_rsa -t rsa -C "#{@email}" -N ""`    # ssh-keygen style key creation
      
      
      # new sshkey gem method...
      # XXX use sshkey gem instead of command line utilitie
      k = SSHKey.generate(:comment => "#{@email}")
      
      publ = k.ssh_public_key
      privl = k.private_key
      
      my_file_privl = File.open(GAS_DIRECTORY + "/#{@uid}_id_rsa",'w',0700)
      my_file_privl.write(privl)
      my_file_privl.close
      
      my_file_publ = File.open(GAS_DIRECTORY + "/#{@uid}_id_rsa.pub",'w',0700)
      my_file_publ.write(publ)
      my_file_publ.close
      
      
      
    end
    
    
    
    def self.user_wants_gas_to_handle_rsa_keys?
      puts "Do you want gas to handle switching rsa keys for this user?"
      puts "[y/n]"
      
      while true
        handle_rsa = STDIN.gets.strip
        
        case handle_rsa
        when "y"
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
                delete "~/.gas/#{@uid}_id_rsa", "~/.gas/#{@uid}_id_rsa.pub"    # TODO:  Test me
                return false
              when "y"
                puts "Excelent!  Gas will handle rsa keys for this user."
                return nil
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
    
    # This function creates the ssh keys if needed and puts them in ~/.gas/NICKNAME_id_rsa and ...rsa.pub
    # 
    # 
    def self.setup_ssh_keys(user)
      @uid = user.nickname                 # TODO: question:  are nicknames allowed to be nil?  If not, this coding can be reduced to one line of code
      @uid = user.name if @uid.nil?
      @email = user.email
      
      if user_wants_gas_to_handle_rsa_keys?
        puts
        
        if user_wants_to_use_key_already_in_gas?
          return true  # because gas directory is already setup
        elsif user_wants_to_use_key_already_in_ssh?   #  Check ~/.ssh for a current id_rsa file, if yes, "Do you want to use the current id_rsa file to be used as your key?"
          use_current_rsa_files_for_this_user    # copies the keys from ~/.ssh instead of generating new keys if desired/possible
          return true
        else
          return generate_new_rsa_keys_in_gas_dir
        end
        
      elsif user_wants_gas_to_handle_rsa_keys?.nil?
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
      `ssh-add -d ~/.ssh/id_rsa` if is_ssh_agent_there?    # remove the current key from the ssh-agent session (key will no longer be used with github)
      
      FileUtils.cp(GAS_DIRECTORY + "/#{@uid}_id_rsa", SSH_DIRECTORY + "/id_rsa") 
      FileUtils.cp(GAS_DIRECTORY + "/#{@uid}_id_rsa.pub", SSH_DIRECTORY + "/id_rsa.pub")  
      
      FileUtils.chmod(0700, SSH_DIRECTORY + "/id_rsa")
      FileUtils.chmod(0700, SSH_DIRECTORY + "/id_rsa.pub")
      
      if is_ssh_agent_there?
        `ssh-add ~/.ssh/id_rsa`  # TODO: you need to run this command to get the private key to be set to active on unix based machines.  Not sure what to do for windows yet...
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
      if File.exists? file_path
        return Digest::MD5.hexdigest(File.open(file_path, "rb").read)
      end
      return nil
    end
  
    
    # TODO:  Uploads the public key to github
    def self.upload_public_key_to_github(user)
      puts "You can paste this key into your git hub account:"
      puts File.open("#{GAS_DIRECTORY}/#{user.nickname}_id_rsa.pub", "rb").read
      return "Impliment me plz!"
      puts "Gas can automatically install this ssh key into the github account of your choice.  Would you like gas to do this for you?  (Requires inputting github username and password)"
      puts "[y/n]"
      
      while true
        upload_key = STDIN.gets.strip
        case upload_key
        when "y"
          key_installation_routine
        when "n"
          return false
        else
          puts "Plz respond 'y' or 'n'"
        end
      end
    end
    
    def self.key_installation_routine
      
      credentials = get_username_and_password_and_authenticate
      
      post_details = log_in_and_figure_out_where_to_post_to
      
      server_response = post_key!
      
    end
    
    def get_username_and_password_and_authenticate
    end
    
    def log_in_and_figure_out_where_to_post_to
    end
    
    def post_key!
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
      # XXX: check if this user's key is also in ~/.ssh
      ssh_file = get_md5_hash("#{SSH_DIRECTORY}/id_rsa")
      gas_file = get_md5_hash("#{GAS_DIRECTORY}/#{nickname}_id_rsa")
      
      return false if gas_file.nil?       # if the gas file doesn't exist, return from this function safely
      
      if ssh_file == gas_file
        File.delete("#{SSH_DIRECTORY}/id_rsa")
        File.delete("#{SSH_DIRECTORY}/id_rsa.pub")
      end
      
      File.delete("#{GAS_DIRECTORY}/#{nickname}_id_rsa")
      File.delete("#{GAS_DIRECTORY}/#{nickname}_id_rsa.pub")
    end
  
  end
end


