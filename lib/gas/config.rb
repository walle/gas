require 'fileutils'

module Gas

  # Class that keeps track of users
  class Config
    attr_reader :users

    # Initializes the object. If no users are supplied we look for a config file, if none then create it, and parse it to load users
    # @param [Array<User>] users The override users
    # @param [String] config The override config
    def initialize(users = nil, config = nil)
      @config_file = File.expand_path('~/.gas')
      @config = ''

      if config.nil?
        if !File.exists? @config_file
          FileUtils.touch @config_file
        end

        @config = File.read(@config_file)
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
      keygen()
    end
    
    # genereates an ssh key if needed
    def keygen
      # if key already exists, overright?
    
      # run ssh-keygen command here, using self.email TODO ###########################

      # store the file in ~/.gas/nickname_id_rsa

      # puts the id_rsa file so you can easily copy and paste it into github
    end

    # Override to_s to output correct format
    def to_s
      @users.join("\n")
    end

  end
end
