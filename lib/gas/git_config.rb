module Gas

  # Class that class that interacts with the git config
  module GitConfig

    # Parse out the current user from the gitconfig
    # @param [String] gitconfig The git configuration
    # @return [Gas::User] The current user or nil if not present
    def self.current_user
      name = `git config --global --get user.name`
      email = `git config --global --get user.email`

      return nil if name.nil? && email.nil?

      User.new name.delete("\n"), email.delete("\n")   # git cli returns the name and email with \n at the end
    end

    # Changes the user
    # @param [Gas::User] user The new user
    def self.change_user(user)
      name = user.name
      email = user.email

      `git config --global user.name "#{name}"`
      `git config --global user.email "#{email}"`
    end

  end
end