module Gas

  # Class that keeps track of users
  class Configuration
    attr_reader :users

    # Parses [User]s from a string of the config file
    # @param [String] config The configuration file
    # @return [Configuration]
    def self.parse(config)
      users = []
      config.scan(/\[(.+)\]\s+name = (.+)\s+email = (.+)/) do |nickname, name, email|
        users << User.new(name, email, nickname)
      end

      Configuration.new users
    end

    # Can parse out the current user from the gitconfig
    # @param [String] gitconfig The git configuration
    # @return [User] The current user
    def self.current_user(gitconfig)
      User.parse gitconfig
    end

    # @param [Array<User>] users
    def initialize(users)
      @users = users
    end

    # Override to_s to output correct format
    def to_s
      @users.join("\n")
    end

  end
end
