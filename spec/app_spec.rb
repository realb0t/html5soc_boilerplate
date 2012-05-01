require File.dirname(__FILE__) + "/spec_helper.rb"

describe "App" do
  before do
  end

  xit "should respond to /" do
    get "/"
    last_response.should be_ok
  end

  after do
  end
end