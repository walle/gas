GAS_DIRECTORY = File.expand_path('~/.gas')
SSH_DIRECTORY = File.expand_path('~/.ssh')

require 'sshkey' #external

require 'gas/version'
require 'gas/ssh'
require 'gas/user'
require 'gas/config'
require 'gas/gitconfig'


module Gas

  @config = Config.new
  @gitconfig = Gitconfig.new

  # Lists all authors
  def self.list
    puts 'Available users:'
    puts @config

    self.show
  end

  # Shows the current user
  def self.show
    user = @gitconfig.current_user

    if user
      puts 'Current user:'
      puts "#{user.name} <#{user.email}>"
      
      if Ssh.corresponding_rsa_files_exist?
        puts "This user's id_rsa key is:"
        puts `cat #{GAS_DIRECTORY}/#{user.nickname}_id_rsa.pub`
      end
      
    else
      puts 'No current user in gitconfig'
    end
  end

  # Sets _nickname_ as current user
  # @param [String] nickname The nickname to use
  def self.use(nickname)
    self.no_user? nickname
    user = @config[nickname]
    
    @gitconfig.change_user user        # daring change made here!  Heads up Walle
    
    self.show
  end

  # Adds a author to the config
  # @param [String] nickname The nickname of the author
  # @param [String] name The name of the author
  # @param [String] email The email of the author
  def self.add(nickname, name, email)
    self.has_user? nickname
    user = User.new name, email, nickname
    @config.add user
    @config.save!
    
    Ssh.setup_ssh_keys user
    
    Ssh.upload_public_key_to_github user
    
    puts 'Added author'
    puts user
  end
  
  
  # Adds an ssh key for the specified user
  def self.ssh(nickname)
    p @config
    if nickname.nil?
      puts "Oh, so you'd like an elaborate explanation on how ssh key juggling works?  Well pull up a chair!"
      puts
      puts "Gas can juggle ssh keys for you.  It works best in a unix based environment (so at least use git bash or cygwin on a windows platform)."
      puts "You will be prompted if you would like to handle SSH keys when you create a new user."
      puts "If you are a long time user of gas, you can add ssh to an author by the command..."
      puts "\$  gas ssh NICKNAME"
      puts "Your ssh keys will be stored in ~/.gas/NICKNAME_id_rsa and automatically copied to ~/.ssh/id_rsa when you use the command..."
      puts "\$  gas use NICKNAME"
      puts "if ~/.ssh/id_rsa already exists, you will be prompted UNLESS that rsa file is already backed up in the .gas directory (I'm so sneaky, huh?)"
      puts "The unix command ssh-add is used in order to link up your rsa keys when you attempt to make an ssh connection (git push uses ssh keys of course)"
      puts
      puts "The ssh feautre of gas offers you and the world greater privacy against corporate databases.  Did you know that IBM built one of the first automated database systems?  These ancient database machines (called tabulators) were used to facilitate the holocaust =("
    else
      user = @config[nickname]
      
      Ssh.setup_ssh_keys user
          
      Ssh.upload_public_key_to_github user
    end
  end
  

    
  
  
  

  # Imports current user from .gitconfig to .gas
  # @param [String] nickname The nickname to give to the new user
  def self.import(nickname)
    self.has_user? nickname
    user = @gitconfig.current_user

    if user
      user = User.new user.name, user.email, nickname

      @config.add user
      @config.save!

      puts 'Added author'
      puts user
    else
      puts 'No current user to import'
    end
  end

  # Deletes an author from the config using nickname
  # @param [String] nickname The nickname of the author
  def self.delete(nickname)
    Ssh.delete nickname
    return false unless self.no_user? nickname        # I re-engineered this section so I could use Gas.delete in a test even when that author didn't exist
                                                      # TODO: The name no_user? is now very confusing.  It should be changed to something like "is_user?" now maybe?
    @config.delete nickname
    @config.save!
    
    Ssh.delete nickname

    puts "Deleted author #{nickname}"
    return true
  end

  # Prints the current version
  def self.version
    puts Gas::VERSION
  end

  # Checks if the user exists and gives error and exit if not
  # @param [String] nickname
  def self.no_user?(nickname)
    if !@config.exists? nickname
      puts "Nickname #{nickname} does not exist"
      return false
    end
    return true
  end

  # Checks if the user exists and gives error and exit if so
  # @param [String] nickname
  def self.has_user?(nickname)
    if @config.exists? nickname
      puts "Nickname #{nickname} does already exist"
      exit
    end
  end

end
