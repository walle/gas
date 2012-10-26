# encoding: utf-8

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

RSpec.configure do |config|
  config.mock_with :rr
end

# Mocks a cli call using ` with rr.
# Takes a block to use as rr return block
# @param [Object] mock_object The object to mock
# @param [String] command The command to mock
def mock_cli_call(mock_object, command)
  # To be able to mock ` (http://blog.astrails.com/2010/7/5/how-to-mock-backticks-operator-in-your-test-specs-using-rr)
  mock(mock_object).__double_definition_create__.call(:`, command) { yield }
end