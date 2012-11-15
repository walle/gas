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

end