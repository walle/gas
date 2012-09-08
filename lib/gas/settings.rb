module Gas

  # Class that contains settings for the app
  class Settings
    attr_accessor :base_dir, :github_server
    attr_reader :gas_dir, :ssh_dir

    def initialize
      @base_dir = '~'
      @gas_dir = "#{@base_dir}/.gas"
      @ssh_dir = "#{@base_dir}/.ssh"
      @github_server = 'api.github.com'
    end

    def configure
      yield self if block_given?
    end

    def gas_dir=(value)
      @gas_dir = "#{@base_dir}/#{value}"
    end

    def ssh_dir=(value)
      @ssh_dir = "#{@base_dir}/#{value}"
    end

  end
end
