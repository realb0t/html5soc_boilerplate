require File.join(File.dirname(__FILE__), 'config', 'environment.rb')
require 'bundler'

Bundler.setup
Bundler.require(:default, ENV["RAKE_ENV"].to_sym)

###########

require "sinatra/activerecord"
require "sinatra/activerecord/rake"
require "rspec/core/rake_task"
require "mongoid"
require 'coffee-script'

desc "Run specs"
task :spec do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = "./spec/**/*_spec.rb"
  end
end

namespace :js do
  desc "compile coffee-scripts from ./src to ./public/javascripts"
  task :compile do
    source = "#{File.dirname(__FILE__)}/src/"
    javascripts = "#{File.dirname(__FILE__)}/public/javascripts/"
    
    Dir.foreach(source) do |cf|
      unless cf == '.' || cf == '..' 
        js = CoffeeScript.compile File.read("#{source}#{cf}") 
        open "#{javascripts}#{cf.gsub('.coffee', '.js')}", 'w' do |f|
          f.puts js
        end 
      end 
    end
  end
end

APP_FILE  = 'app.rb'
APP_CLASS = 'App'

require 'sinatra/assetpack/rake'

namespace :deploy do

  root_path  = File.dirname(__FILE__)
  assets_path = File.join(root_path, 'public', 'assets')
  scripts_path = File.join(root_path, 'public', 'scripts')
  styles_path = File.join(root_path, 'public', 'styles')
  release_file = File.join(root_path, 'FRONT_RELEASE')
  release_dir = File.join(root_path, 'public', 'javascript')

  desc 'Rebuild old assets'
  task :rebuild_assets => [ :remove_assets, :create_assets ]

  desc 'Remove old assets'
  task :remove_assets do

    if FileTest.exists?(assets_path)
      puts ">>> Clear #{assets_path} ..."
      FileUtils.rm_rf(assets_path) 
    end

    if FileTest.exists?(scripts_path)
      puts ">>> Clear #{scripts_path} ..."
      FileUtils.rm_rf(scripts_path)
    end

    if FileTest.exists?(styles_path)
      puts ">>> Clear #{styles_path} ..."
      FileUtils.rm_rf(styles_path)
    end
   
  end

  desc 'Create current assets'
  task :create_assets do
    if Rake::Task["assetpack:build"]
      puts '>>> Start build assetpack ...'
      Rake::Task["assetpack:build"].invoke
    else
      throw 'Not exist task assetpack:build'
    end
  end

  desc 'Make release with assets'
  task :clear_releases do
    puts '>>> Start find old releases'
    require 'find'
    ::Find.find(release_dir) do |file|
      if file.match /(.*)main\-build\.(.*)\.js/
        puts '    delete: ' + file
        File.delete(file) 
      end
    end
  end

  desc 'Make release with assets'
  task :make_release do
    throw 'Not found assets path' unless FileTest.exists?(assets_path)
    throw 'Not found scripts path' unless FileTest.exists?(scripts_path)
    throw 'Not found styles path' unless FileTest.exists?(styles_path)

    timestamp = Digest::MD5.hexdigest(Time.now.to_f.to_s)

    File.open(release_file, 'w'){ |file| file.write timestamp }

    release_out_file = File.join(release_dir, "main-build.#{timestamp}.js")

    puts ">>> Start make release: #{release_out_file} ..."
    puts %x{node r.js -o build.js out=#{release_out_file}}
  end

  desc "Deploy frontend application to main-build.<release_hash>.js"
  task :front => [ :remove_assets, :create_assets, :clear_releases, :make_release ] do
    puts 'Building release has been completed!'
  end

end