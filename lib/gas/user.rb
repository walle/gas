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
      "      [#{use_nickname ? @nickname : 'user'}]\n         name = #{@name}\n         email = #{@email}"
    end

  # Define the equality operator to test if two user objects are the same
  def ==(user)
    return false unless user.is_a? User
    unless nickname.empty? || user.nickname.empty? # Don't test equallity in nickname if any of the nicknames is not used
      return false unless nickname == user.nickname
    end
    return (name == user.name && email == user.email)
  end

  end
end