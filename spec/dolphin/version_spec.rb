require 'spec_helper'

describe Dolphin::VERSION do

  it "must be defined" do
    Dolphin::VERSION.wont_be_nil
  end

end
