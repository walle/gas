require 'fileutils'

module Gas

  # Class that keeps track of users
  class Users
    attr_reader :users

    # Initializes the object. If no users are supplied we look for a config file, if none then create it, and parse it to load users
    # @param [String] config_file The path to the file that stores users
    def initialize(config_file)
      @config_file = config_file
      @users = []

      setup!
    end

    # Checks if a user with _nickname_ exists
    # @param [String] nickname
    # @return [Boolean]
    def exists?(nickname)
      users.each do |user|
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
      users.each do |user|
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
      users.map do |user|
        if current_user == user
          "  ==> #{user.to_s[5,user.to_s.length]}"
        else
          user.to_s
        end
      end.join "\n"
    end

    def setup!
      ensure_config_directory_exists!
      load_config
      load_users
    end

    private

    def ensure_config_directory_exists!
      unless File.exists? File.dirname(@config_file)
        Dir::mkdir File.dirname(@config_file)
        FileUtils.touch @config_file
      end
    end

    def load_config
      @config = File.read @config_file
    end

    def load_users
      @config.scan(/\[(.+)\]\s+name = (.+)\s+email = (.+)/) do |nickname, name, email|
        @users << User.new(name, email, nickname)
      end
    end
  end
end