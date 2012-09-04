module Gas
  module Prompter
    
    @invalid_input_response_with_default = "Please use 'y' or 'n' or enter for default."
    # If the user says 'f', the system will
    #   report that there isn't an id_rsa already in gas.  This causes a new key to overwrite automatically down the road.
    # This is for checking if a .gas/rsa file already exists for a nickname which is being registered
    # If the rsa exists, then we're goona need to ask if we should use it, or if we should delete it
    #
    # Returns true to indicate that the user would like to use the rsa file already in .gas ()
    # Returns false when there is no naming conflicts.
    def self.user_wants_to_use_key_already_in_gas?
      puts "Gas has detected a key in its archive directory ~/.gas/#{@uid}_id_rsa.  Should gas use this key or overwrite this key with a brand new one?"
      puts "Keep current key? [y/n]"

      while true
        keep_current_file = clean_gets

        case keep_current_file

        when "y"
          return true # keep the files already in .gas, skip making key.
        when "n"
          return false
        else
          puts "please respond 'y' or 'n'"
        end
      end
    end
    
    
    #  Checks if the ~/.ssh directroy contains id_rsa and id_rsa.pub
    #  if it does, it asks the user if they would like to use that as their ssh key, instead of generating a new key pair.
    #
    def self.user_wants_to_use_key_already_in_ssh?
      return false unless Gas::Ssh.ssh_dir_contains_rsa?

      #puts "Gas has detected that an ~/.ssh/id_rsa file already exists.  Would you like to use this as your ssh key to connect with github?  Otherwise a new key will be generated and stored in ~/.gas (no overwrite concerns until you 'gas use nickname')"
      puts "Generate a brand new ssh key pair?  (Choose 'n' to use key in ~/.ssh/id_rsa)"
      puts "Default: 'y'"
      puts "[Y/n]"

      while true
        generate_new_rsa = clean_gets.downcase
        case generate_new_rsa
          when "y", ""
            return false
          when "n"
            return true # return true if we aren't generating a new key
          else
            puts @invalid_input_response_with_default
        end
      end
    end
    
    
    def self.user_wants_gas_to_handle_rsa_keys?
      puts "Do you want gas to handle switching rsa keys for this user?"
      puts "[Y/n]"

      while true
        handle_rsa = clean_gets

        case handle_rsa
        when "y", ""
          return true
        when "n"
          puts
          # check if ~/.gas/rsa exists, if it does, promt the user
          if Gas::Ssh.corresponding_rsa_files_exist? #in ~/.gas/

            puts "Well... there's already a ~/.gas/#{@uid}_id_rsa configured and ready to go.  Are you sure you don't want gas to handle rsa switching?  (Clicking no will delete the key from the gas directory)"
            puts "Just let gas handle ssh key for this user? [y/n]"

            while true
              keep_file = clean_gets

              case keep_file
              when "n"
                delete "#{GAS_DIRECTORY}/#{@uid}_id_rsa", "#{GAS_DIRECTORY}/#{@uid}_id_rsa.pub"
                return false
              when "y"
                puts "Excelent!  Gas will handle rsa keys for this user."
                return nil
              else
                puts @invalid_input_response_with_default
              end
            end
          end
          return false

        else
          puts "Please use 'y' or 'n'"
        end
      end
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
        delete_all_keys = clean_gets

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
    
    
    def self.user_wants_to_install_key_to_github?
      puts "Gas can automatically install this ssh key into the github account of your choice.  Would you like gas to do this for you?  (Requires inputting github username and password)"
      puts "[Y/n]"

      while true
        upload_key = clean_gets.downcase
        case upload_key
        when "y", ""
          return true
        when "n"
          return false
        else
          puts @invalid_input_response_with_default
        end
      end
    end
    
    
    def self.user_wants_to_overwrite_existing_rsa_key?
      puts "~/.ssh/id_rsa already exists.  Overwrite?"
      puts "[y/n]"

      while true
        overwrite = clean_gets
        case overwrite
          when "y"
            return true
          when "n"
            return false
          else
            puts "please respond 'y' or 'n'"
        end
      end
    end
    
    
    # If the user hits ctrl+c with this, it will exit cleanly
    def self.clean_gets
      begin
        getit = STDIN.gets.strip
      rescue SystemExit, Interrupt           # catch if they hit ctrl+c
        puts
        puts "Safely aborting operation..."    # reassure user that ctrl+c is fine to use.  
        exit
      end
      
      return getit
    end

  end
end