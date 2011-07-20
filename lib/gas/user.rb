module Gas

  # Class that contains data for a git user
  class User
    attr_reader :name, :email

    # Static function to parse out the data from a git config string
    # @param [String] gitconfig
    # @return [User] a new user
    def self.parse(gitconfig)
      regex = /\[user\]\s+name = (.+)\s+email = (.+)/
      matches = regex.match gitconfig

      User.new matches[1], matches[2]
    end

    # @param [String] name The name of the user
    # @param [String] email The email of the user
    def initialize(name, email)
      @name = name
      @email = email
    end

    # Overides to_s to output in the correct format
    # @return [String]
    def to_s
      "[user]\n  name = #{@name}\n  email = #{@email}"
    end

  end
end
