require 'fileutils'

require 'gas/version'
require 'gas/user'
require 'gas/config'

# TODO: Refactor this file

module Gas

  @config = File.expand_path('~/.gas')
  @gitconfig = File.expand_path('~/.gitconfig')

  # Lists all authors
  def self.list
    if !File.exists? @config
      FileUtils.touch @config
    end

    config = File.read(@config)
    configuration = Config.parse config
    puts 'Available users:'
    puts configuration

    self.show
  end

  # Shows the current user
  def self.show
    gitconfig = File.read(@gitconfig)
    user = Gas::Config.current_user gitconfig
    puts 'Current user:'
    puts "#{user.name} <#{user.email}>"
  end

  # Sets _nickname_ as current user
  # @param [String] nickname The nickname to use
  def self.use(nickname)
    if !File.exists? @config
      FileUtils.touch @config
    end

    config = File.read(@config)
    configuration = Config.parse config

    if !configuration.exists? nickname
      puts "Nickname #{nickname} does not exist"
      return
    end

    user = configuration[nickname]

    gitconfig = File.read(@gitconfig)
    gitconfig.gsub! /name\s?=\s?.+/, "name = #{user.name}"
    gitconfig.gsub! /email\s?=\s?.+/, "email = #{user.email}"
    File.open @gitconfig, 'w' do |file|
      file.write gitconfig
    end

    self.show
  end

  # Adds a author to the config
  # @param [String] nickname The nickname of the author
  # @param [String] name The name of the author
  # @param [String] email The email of the author
  def self.add(nickname, name, email)
    config = File.read(@config)
    configuration = Config.parse config

    if configuration.exists? nickname
      puts "Nickname #{nickname} does already exist"
      return
    end

    user = User.new name, email, nickname
    configuration.add user
    File.open @config, 'w' do |file|
      file.write configuration
    end

    puts 'Added author'
    puts user
  end

  # Deletes a author from the config using nickname
  # @param [String] nickname The nickname of the author
  def self.delete(nickname)
    config = File.read(@config)
    configuration = Config.parse config

    if !configuration.exists? nickname
      puts "Nickname #{nickname} does not exist"
      return
    end

    configuration.delete nickname
    File.open @config, 'w' do |file|
      file.write configuration
    end

    puts "Deleted author #{nickname}"
  end

  # Prints the current version
  def self.version
    puts Gas::VERSION
  end

end
