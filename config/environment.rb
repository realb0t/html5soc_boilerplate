require 'yaml'

APP_CONF = Hash.new do |hash, key|
  hash[key.to_s] = YAML.load(File.read(File.join(File.dirname(__FILE__), key.to_s + '.yml')))[ENV['RACK_ENV']]
end

ENV["RACK_ENV"] ||= "development"
ENV["RAKE_ENV"] ||= ENV["RACK_ENV"]
ENV["APP_ENV"]  ||= ENV["RACK_ENV"]
ENV["MONGO_URL"] ||= ENV["MONGOHQ_URL"] || "mongodb://#{APP_CONF['mongoid']['host']}/#{APP_CONF['mongoid']['database']}"