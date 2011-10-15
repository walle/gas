require 'fileutils'

module Gas

  # Class that keeps track of users
  class Config
    attr_reader :users

    # This function checks for a ~/.gas FILE and if it exists, it puts it into memory and deletes it from the HDD
    # then it creates the ~/.gas FOLDER and saves the old .gas file as ~/git.conf
    #
    def migrate_to_gas_dir!
      old_config_file = File.expand_path('~/.gas')
      config_dir = File.expand_path('~/.gas')
      new_config_file = File.expand_path('~/.gas') + "/gas.authors"

      if File.file? old_config_file
        file = File.open(old_config_file, "rb")
        contents = file.read
        file.close

        File.delete old_config_file

        Dir::mkdir(config_dir)

        file = File.new(new_config_file, "w")
        file.puts contents
        file.close
      end
    end


    # Initializes the object. If no users are supplied we look for a config file, if none then create it, and parse it to load users
    # @param [Array<User>] users The override users
    # @param [String] config The override config
    def initialize(users = nil, config = nil)
      migrate_to_gas_dir! # Migrates old users to the new configuration file location, how thoughtful of me, I know
      @config_file = File.expand_path('~/.gas/gas.authors')
      @gas_dir = File.expand_path('~/.gas')
      @config = ''

      if config.nil?
        if !File.exists? @config_file
          Dir::mkdir(@gas_dir)
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
    end


    # Override to_s to output correct format
    def to_s
      gc = Gitconfig.new

      users = @users.map do |user|
        if is_current_user(gc.current_user_object[:name], gc.current_user_object[:email], user.to_s)
          "  ==>" + user.to_s[5,user.to_s.length]
        else
          user.to_s
        end
      end.join("\n")

      return users
    end


    # Scans the @users (a string containing info formatted identical to the gas.author file)
    #  ...and checks to see if it's name and email match what you're looking for
    def is_current_user(name, email, object)
      object.scan(/\[(.+)\]\s+name = (.+)\s+email = (.+)/) do |nicknamec, namec, emailc|
        if namec == name and emailc == email
          #  check if ssh is active
          # TODO:  Check if its SSH key is setup, and indicate SSH ACTIVE
          return true
        end
      end
      return false   # could not get a current user's nickname
    end

  end
end
