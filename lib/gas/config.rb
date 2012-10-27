require 'fileutils'

module Gas

  # Class that keeps track of users
  # TODO: Has code only used to test the class, write integration test instead?
  class Config
    attr_reader :users

    # Initializes the object. If no users are supplied we look for a config file, if none then create it, and parse it to load users
    # @param [Array<User>] users The override users
    # @param [String] config The override config
    def initialize(users = nil, config = nil)
      @config_file = File.join GAS_DIRECTORY, GAS_USERS_FILENAME

      if config.nil?
        unless File.exists? GAS_DIRECTORY
          Dir::mkdir GAS_DIRECTORY
          FileUtils.touch @config_file
        end

        @config = File.read @config_file
      else
        @config = config
      end

      if users.nil?
        @users = []
        @config.scan(/\[(.+)\]\s+name = (.+)\s+email = (.+)/) do |nickname, name, email|
          @users << User.new(name, email, nickname)
        end
      else
        @users = users
      end
    end

    # Checks if a user with _nickname_ exists
    # @param [String] nickname
    # @return [Boolean]
    def exists?(nickname)
      @users.each do |user|
        if user.nickname == nickname
          return true;
        end
      end

      false
    end

    # Returns the user with nickname nil if no such user exists
    # @param [String|Symbol] nickname
    # @return [User|nil]
    def get(nickname)
      @users.each do |user|
        if user.nickname == nickname.to_s
          return user
        end
      end

      nil
    end

    # Override [] to get hash style acces to users
    # @param [String|Symbol] nickname
    # @return [User|nil]
    def [](nickname)
      get nickname
    end

    # Adds a user
    # @param [User]
    def add(user)
      @users << user
    end

    # Deletes a user by nickname
    # @param [String] nickname The nickname of the user to delete
    def delete(nickname)
      @users.delete_if do |user|
        user.nickname == nickname
      end
    end

    # Saves the current users to the config file
    def save!
      File.open @config_file, 'w' do |file|
        file.write self
      end
    end

    # Override to_s to output correct format
    def to_s
      current_user = GitConfig.current_user
      @users.map do |user|
        if current_user == user
          "  ==> #{user.to_s[5,user.to_s.length]}"
        else
          user.to_s
        end
      end.join "\n"
    end
  end
end