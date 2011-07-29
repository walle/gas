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
    end

  end
end

