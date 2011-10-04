module Gas

  # Class that contains data for a git user
  class User
    attr_reader :name, :email, :nickname

    # @param [String] name The name of the user
    # @param [String] email The email of the user
    # @param [String] nickname A nickname for the user, not used when parsing from gitconfig
    def initialize(name, email, nickname = '')
      @name = name
      @email = email
      @nickname = nickname
      
      # TODO ##################################################
      #  Notes:  Check and see if i need to "require" ssh-keygen or something like that.  
      #
      # 1)  Prompt user if they would like gas to juggle SSH keys for them
      #       <Assume yes>
      #
      # 2)  Check for a current id_rsa file, if yes, "Do you want to use the current id_rsa file to be used as your key?"
      #       <Assume yes>
      #
      #   2.1 Check if id_rsa is a clone of another stored id_rsa and prompt user to make sure they're aware
      #      and want to proceed anyway, or if they'd like to generate a new id_rsa
      #
      # Generate sshkey
      puts "Generating ssh new ssh key"
      
      # ssh-keygen -f ~/id_rsa -t rsa -C "INSERT@EMAIL.COM"
      # 
      #   
      
    end

    # Returns the git format of user
    # @return [String]
    def git_user
      to_s false
    end

    # Overides to_s to output in the correct format
    # @param [Boolean] use_nickname Defaults to true
    # @return [String]
    def to_s(use_nickname = true)
      "[#{use_nickname ? @nickname : 'user'}]\n  name = #{@name}\n  email = #{@email}"
    end

  end
end
