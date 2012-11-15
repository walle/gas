require './spec/spec_helper'

require './lib/gas'

describe Gas do

  before :each do

  end

  it 'should show correct version' do
    output = capture_stdout { Gas.print_version }
    output.should == "#{Gas::VERSION}\n"
  end

  it 'should show correct usage' do
    output = capture_stdout { Gas.print_usage }
    output.should == "Usage: \n"
  end

  it 'should return if correct number of params is supplied' do
    mock(ARGV).length { 3 }
    lambda { Gas.check_parameters( 3, 'Nope') }.should_not raise_error SystemExit
  end

  it 'should exit if incorrect number of params is supplied' do
    mock(ARGV).length { 3 }
    lambda { Gas.check_parameters( 4, 'Error message') }.should raise_error SystemExit
  end

end