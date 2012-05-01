require "rubygems"
require "spork"

require "bundler/setup"

ENV["RACK_ENV"] = "test"

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you"ll
  # need to restart spork for it take effect.
  require "sinatra"
  Bundler.require(:default, Sinatra::Application.environment)
  require "rspec"
  require "rack/test"
  require "factory_girl"
  require "factory_girl_rspec"
  require File.join(File.dirname(__FILE__), "..", "app.rb")
  Dir[File.dirname(__FILE__) + "/factories/*.rb"].each { |f| require f }

  enable :sessions

  disable :run
  enable :raise_errors
  disable :logging

  RSpec.configure do |conf|
    conf.include Rack::Test::Methods
    conf.mock_with :rspec
    conf.color_enabled = true
    # conf.full_backtrace = true
  end

  def app
    Sinatra::Application
  end

  def session
    last_request.env["rack.session"]
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  
end

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading 
#   code that you don't normally modify during development in the 
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - These instructions should self-destruct in 10 seconds.  If they don't,
#   feel free to delete them.
#