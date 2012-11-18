require 'gas/version'
require 'gas/user'
require 'gas/users'
require 'gas/git_config'

GAS_DIRECTORY = File.expand_path '~/.gas'
OLD_GAS_USERS_FILENAME = 'gas.authors'
GAS_USERS_FILENAME = 'users'

module Gas

  @users = Users.new(File.join GAS_DIRECTORY, GAS_USERS_FILENAME)

  # Print version information to stdout
  def self.print_version
    puts Gas::VERSION
  end

  # Print usage information to stdout
  def self.print_usage
    puts "Usage: command [parameters]\n\nBuilt-in commands:\n   add NICKNAME NAME EMAIL - adds a new user to gas\n   delete NICKNAME - deletes a user from gas\n   import NICKNAME - imports the user from .gitconfig into NICKNAME\n   list - lists all users\n   plugins - lists all installed plugins\n   show - shows the current user\n use NICKNAME - sets the user with NICKNAME as the current user"
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

  # Checks if the user exists and gives error and exit if not
  # @param [String] nickname
  def self.check_if_user_does_not_exist(nickname)
    if !users.exists? nickname
      puts "Nickname #{nickname} does not exist"
      exit
    end
  end

  # Checks if the user exists and gives error and exit if so
  # @param [String] nickname
  def self.check_if_user_already_exists(nickname)
    if users.exists? nickname
      puts "Nickname #{nickname} already exists"
      exit
    end
  end

  # Lists all authors
  def self.list
    puts
    puts 'Available users:'
    puts
    puts users
    puts
  end

  # Shows the current user
  def self.show
    user = GitConfig.current_user

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
    check_if_user_does_not_exist(nickname)

    user = users.get nickname
    GitConfig.change_user user
    self.show
  end

  # Adds a author to the config
  # @param [String] nickname The nickname of the author
  # @param [String] name The name of the author
  # @param [String] email The email of the author
  def self.add(nickname, name, email)
    check_if_user_already_exists(nickname)

    user = User.new name, email, nickname
    users.add user
    users.save!

    puts 'Added new author'
    puts user
  end

  # Imports current user from .gitconfig to .gas
  # @param [String] nickname The nickname to give to the new user
  def self.import(nickname)
    check_if_user_already_exists(nickname)

    user = GitConfig.current_user

    if user
      user = User.new user.name, user.email, nickname

      users.add user
      users.save!

      puts 'Imported author'
      puts user
    else
      puts 'No current user to import'
    end
  end

  # Deletes an author from the config using nickname
  # @param [String] nickname The nickname of the author
  def self.delete(nickname)
    check_if_user_does_not_exist(nickname)

    users.delete nickname
    users.save!

    puts "Deleted author #{nickname}"
    return true
  end

  # Returns the users object so we don't use it directly
  # @return [Gas::Users]
  def self.users
    @users
  end
end