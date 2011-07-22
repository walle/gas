module Gas

  # Class that class that interacts with the .gitconfig
  class Gitconfig

    def initialize(gitconfig = nil)
      @gitconfig_file = File.expand_path('~/.gitconfig')
      @gitconfig = ''

      if gitconfig.nil? && File.exists?(@gitconfig_file)
        @gitconfig = File.read(@gitconfig_file)
      elsif !gitconfig.nil?
        @gitconfig = gitconfig
      end
    end

    # Parse out the current user from the gitconfig
    # TODO: Error handling
    # @param [String] gitconfig The git configuration
    # @return [User] The current user or nil if not present
    def current_user
      regex = /\[user\]\s+name = (.+)\s+email = (.+)/
      matches = regex.match @gitconfig

      return nil if matches.nil?

      User.new matches[1], matches[2]
    end

    # Changes the user
    # @param [String] name The new name
    # @param [String] email The new email
    def change_user(name, email)
      if current_user_present?
        @gitconfig.gsub! /^\s*name\s?=\s?.+/, "  name = #{name}"
        @gitconfig.gsub! /^\s*email\s?=\s?.+/, "  email = #{email}"
      else
        create_user(name, email)
      end
    end

    # Create a user section
    # @param [String] name The new name
    # @param [String] email The new email
    def create_user(name, email)
      return if current_user_present?

      @gitconfig << <<-EOS

# Those lines are added by gas, feel free to change them.
[user]
  name = #{name}
  email = #{email}
      EOS
    end

    # Check if user section is present in gitconfig
    def current_user_present?
      !current_user.nil?
    end

    # Saves the gitconfig
    def save!
      File.open @gitconfig_file, 'w' do |file|
        file.write @gitconfig
      end
    end

  end
end

