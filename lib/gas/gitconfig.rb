module Gas

  # Class that class that interacts with the .gitconfig
  class Gitconfig

    def initialize(gitconfig = nil)
      @gitconfig_file = File.expand_path('~/.gitconfig')
      @gitconfig = ''

      if gitconfig.nil?
        @gitconfig = File.read(@gitconfig_file)
      else
        @gitconfig = gitconfig
      end
    end

    # Parse out the current user from the gitconfig
    # TODO: Error handling
    # @param [String] gitconfig The git configuration
    # @return [User] The current user
    def current_user
      regex = /\[user\]\s+name = (.+)\s+email = (.+)/
      matches = regex.match @gitconfig

      User.new matches[1], matches[2]
    end

    # Changes the user
    # @param [String] name The new name
    # @param [String] email The new email
    def change_user(name, email)
      @gitconfig.gsub! /^\s*name\s?=\s?.+/, "  name = #{name}"
      @gitconfig.gsub! /^\s*email\s?=\s?.+/, "  email = #{email}"
    end

    # Saves the gitconfig
    def save!
      File.open @gitconfig_file, 'w' do |file|
        file.write @gitconfig
      end
    end

  end
end

