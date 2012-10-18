require './spec/spec_helper'

require './lib/gas'

describe Gas::Settings do

  before(:all) do
    @subject = Gas::Settings.new
  end

  it 'should respond to base_dir' do
    @subject.should respond_to :base_dir
  end

  it 'should give default value for base_dir' do
    @subject.base_dir.should == '~'
  end

  it 'should respond to gas_dir' do
    @subject.should respond_to :gas_dir
  end

  it 'should give default value for gas_dir' do
    @subject.gas_dir.should == "#{@subject.base_dir}/.gas"
  end

  it 'should respond to ssh_dir' do
    @subject.should respond_to :ssh_dir
  end

  it 'should give default value for ssh_dir' do
    @subject.ssh_dir.should == "#{@subject.base_dir}/.ssh"
  end

  it 'should respond to github_server' do
    @subject.should respond_to :github_server
  end

  it 'should give default value for github_server' do
    @subject.github_server.should == 'api.github.com'
  end

  it 'should be configurable' do
    @subject.configure do |s|
      s.base_dir = 'test'
      s.gas_dir = 'foo'
      s.ssh_dir = 'bar'
      s.github_server = 'foobar'
    end
    @subject.base_dir.should eq 'test'
    @subject.gas_dir.should eq "#{@subject.base_dir}/foo"
    @subject.ssh_dir.should eq "#{@subject.base_dir}/bar"
    @subject.github_server.should eq 'foobar'
  end

end
