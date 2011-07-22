require 'gas/version'
require 'gas/user'
require 'gas/config'
require 'gas/gitconfig'

module Gas

  @config = Config.new
  @gitconfig = Gitconfig.new

  # Lists all authors
  def self.list
    puts 'Available users:'
    puts @config

    self.show
  end

  # Shows the current user
  def self.show
    user = @gitconfig.current_user

    if user
      puts 'Current user:'
      puts "#{user.name} <#{user.email}>"
    else
      puts 'No current user in gitconfig'
    end
  end

  # Sets _nickname_ as current user
  # @param [String] nickname The nickname to use
  def self.use(nickname)
    self.no_user? nickname
    user = @config[nickname]

    @gitconfig.change_user user.name, user.email
    @gitconfig.save!

    self.show
  end

  # Adds a author to the config
  # @param [String] nickname The nickname of the author
  # @param [String] name The name of the author
  # @param [String] email The email of the author
  def self.add(nickname, name, email)
    self.has_user? nickname
    user = User.new name, email, nickname
    @config.add user
    @config.save!

    puts 'Added author'
    puts user
  end

  # Deletes a author from the config using nickname
  # @param [String] nickname The nickname of the author
  def self.delete(nickname)
    self.no_user? nickname
    @config.delete nickname
    @config.save!

    puts "Deleted author #{nickname}"
  end

  # Prints the current version
  def self.version
    puts Gas::VERSION
  end

  # Checks if the user exists and gives error and exit if not
  # @param [String] nickname
  def self.no_user?(nickname)
    if !@config.exists? nickname
      puts "Nickname #{nickname} does not exist"
      exit
    end
  end

  # Checks if the user exists and gives error and exit if so
  # @param [String] nickname
  def self.has_user?(nickname)
    if @config.exists? nickname
      puts "Nickname #{nickname} does already exist"
      exit
    end
  end

end
