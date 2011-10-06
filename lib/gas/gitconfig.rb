module Gas

  # Class that class that interacts with the git config
  class Gitconfig

    # Parse out the current user from the gitconfig
    # @param [String] gitconfig The git configuration
    # @return [User] The current user or nil if not present
    def current_user
      name = `git config --global --get user.name`
      email = `git config --global --get user.email`

      return nil if name.nil? && email.nil?

      User.new name.delete("\n"), email.delete("\n") # git cli returns the name and email with \n at the end
    end

    # Changes the user
    # @param [String] name The new name
    # @param [String] email The new email
    def change_user(name, email)
      `git config --global user.name "#{name}"`
      `git config --global user.email "#{email}"`
      
      # confirm that this user has a
      return true if Ssh.!user_has_ssh?
      
      
      
      # Verify that the current id_rsa is backed up elsewhere in ~/.gas/
      # If not, prompt the user "The current id_rsa could not be found in the .gas directory."
      # "Are you sure you would like to Overright the current rsa keys?"
      
      # rename the name_id_rsa and name_id_rsa.pub to id_rsa and id_rsa.pub
    end

  end
end

