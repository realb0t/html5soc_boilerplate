require File.join(File.dirname(__FILE__), 'config', 'environment.rb')
require 'bundler'

Bundler.setup
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

require File.join(File.dirname(__FILE__), 'app.rb')