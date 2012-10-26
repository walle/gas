GAS_DIRECTORY = "#{ENV['HOME']}/.gas" # File.expand_path('~/.gas')

require 'gas/version'
require 'gas/user'
require 'gas/config'
require 'gas/gitconfig'
require 'gas/settings'

module Gas

  @config = Config.new
  @gitconfig = Gitconfig.new

  def self.print_version
    puts Gas::VERSION
  end

  def self.print_usage
    puts 'Usage: '
  end

  # Checks the number of parameters and exits with a message if wrong number of parameters is supplied
  # @param [Integer] number_of_parameters_required
  # @param [String] message
  def self.check_parameters(number_of_parameters_required, message)
    unless ARGV.length == number_of_parameters_required
      puts message
      exit
    end
  end

  # Lists all authors
  def self.list
    puts
    puts 'Available users:'
    puts
    puts @config
    puts
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
    return false unless self.no_user?(nickname)
    user = @config[nickname]

    @gitconfig.change_user user        # daring change made here!  Heads up Walle

    self.show
  end

  # Adds a author to the config
  # @param [String] nickname The nickname of the author
  # @param [String] name The name of the author
  # @param [String] email The email of the author
  def self.add(nickname, name, email, github_speaker = nil)
    return false if self.has_user?(nickname)
    user = User.new name, email, nickname
    @config.add user
    @config.save!

    puts 'Added new author'
    puts user
  end

  # Imports current user from .gitconfig to .gas
  # @param [String] nickname The nickname to give to the new user
  def self.import(nickname)
    return false if self.has_user?(nickname)
    user = @gitconfig.current_user

    if user
      user = User.new user.name, user.email, nickname

      @config.add user
      @config.save!

      puts 'Added author'
      puts user
    else
      puts 'No current user to import'
    end
  end

  # Deletes an author from the config using nickname
  # @param [String] nickname The nickname of the author
  def self.delete(nickname)

    return false unless self.no_user? nickname        # I re-engineered this section so I could use Gas.delete in a test even when that author didn't exist
                                                      # TODO: The name no_user? is now very confusing.  It should be changed to something like "user_exists?" now maybe?
    @config.delete nickname
    @config.save!

    puts "Deleted author #{nickname}"
    return true
  end

  # Checks if the user exists and gives error and exit if not
  # @param [String] nickname
  def self.no_user?(nickname)
    if !@config.exists? nickname
      puts "Nickname #{nickname} does not exist"
      return false
    end
    return true
  end

  # Checks if the user exists and gives error and exit if so
  # @param [String] nickname
  def self.has_user?(nickname)
    if @config.exists? nickname
      puts "Nickname #{nickname} already exists"
      return true
    end
    return false
  end

end
