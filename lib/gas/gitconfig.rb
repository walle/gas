module Gas

  # Class that class that interacts with the git config
  class Gitconfig
    @@nickname = ''
    # Parse out the current user from the gitconfig
    # @param [String] gitconfig The git configuration
    # @return [User] The current user or nil if not present
    def current_user
      name = `git config --global --get user.name`
      email = `git config --global --get user.email`
      
      return nil if name.nil? && email.nil?

      User.new name.delete("\n"), email.delete("\n"), @@nickname # git cli returns the name and email with \n at the end
    end

    # Changes the user
    # @param [String] name The new name
    # @param [String] email The new email
    def change_user(user)
      nickname = user.nickname
      @@nickname = nickname                  # maybe we should make nickname a class variable?
      name = user.name
      email = user.email
      
      
      `git config --global user.name "#{name}"`
      `git config --global user.email "#{email}"`
      
      # confirm that this user has an ssh and if so, swap it in safely
      Ssh.swap_in_rsa nickname
      
      
      # Verify that the current id_rsa is backed up elsewhere in ~/.gas/
      # If not, prompt the user "The current id_rsa could not be found in the .gas directory."
      # "Are you sure you would like to Overright the current rsa keys?"
      
      # rename the name_id_rsa and name_id_rsa.pub to id_rsa and id_rsa.pub
    end

  end
end

