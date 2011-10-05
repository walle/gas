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
      
      
      setup_ssh_keys
      
      output_sshkey_to_paste_to_github
      
      
      #  TODO Gas can automatically install this ssh key into the github account of your choice.  Would you like gas to do this for you?  (requires github username/pass)
      
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
