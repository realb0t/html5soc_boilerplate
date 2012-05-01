# coding: utf-8 
require 'bundler/setup'
require './models/user.rb'
require './lib/before_only_filter'
require './lib/soc_authorization'
require './lib/front_release'

module Social
  module Network
    class Vk
      def rate
        1 # TODO: потом вынести в конфиг
      end
    end
  end
end

class App < Sinatra::Base

  configure :development do
    enable :sessions, :clean_trace
    disable :logging, :dump_errors
  end

  configure do
    set :app_file, __FILE__
    set :root, File.dirname(__FILE__)
    set :server, %w[thin mongrel webrick]
    set :haml, :format => :html5
    set :protection, :except => :frame_options
    mime_type :js, 'text/javascript'

    enable :static, :sessions

    set :sass, Compass.sass_engine_options
    set :sass, { :load_paths => sass[:load_paths] + [ "#{App.root}/assets/styles" ] }
    set :scss, sass

    Mongoid.configure do |config|
      conn = Mongo::Connection.from_uri(ENV['MONGO_URL'])
      uri = URI.parse(ENV['MONGO_URL'])
      config.master = conn.db(uri.path.gsub(/^\//, ''))
    end
  end

  configure :production do
    require 'newrelic_rpm'
  end

  ### Include compass support

  register Sinatra::CompassSupport

  compass                  = Compass.configuration
  compass.project_path     = root
  compass.images_dir       = "public/images"
  compass.http_images_path = "/images"

  ### Include asset pack support

  register Sinatra::AssetPack

  assets do

    serve "/scripts", :from => 'assets/scripts'
    serve "/styles", :from => 'assets/styles'

    js_compression :jsmin
    css_compression :sass

    js :require, [
      '/scripts/vendor/require/require.js'
      # сюда добавляем либы которые не подгружается с помощью require.js
    ]

    js :ok, [
      #'http://api.odnoklassniki.ru/js/fapi.js'
      '/javascript/apis/ok.js'
    ]

    js :vk, [
      #'http://vkontakte.ru/js/api/xd_connection.js?20'
      '/javascript/apis/vk.js'
    ]

    js :build, [
      "/javascript/main-build.#{FrontRelease.hash}.js"
    ]

    css :main, '/styles/application.css', [
      '/styles/*.css'
    ]

    prebuild true
  end

  helpers do

    def auth_params
      params.slice(
        :social_env,
        :soc_prefix,
        :soc_type,
        :soc_id
      )
    end

    def is_opera_browser?
      !!request.env['HTTP_USER_AGENT'].downcase.index('opera')
    end

  end

  ### Authentication

  before '*.json' do
    content_type :json
  end

  before do
    headers("P3P" => 'CP="CAO PSA OUR"')
    #'IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT'
  end

  register BeforeOnlyFilter
  include SocAuthorization
  before_only [  '/',  '/messages/*', '/messages', '/synergy_config.js', '/user/*' ] do 
    authorization! 
  end

  error SocAuthorization::Exception do
    { :type => 'error', :message => env['sinatra.error'].message, :data => env['sinatra.error'].backtrace }.to_json
  end

  ### Actions

  get '/' do
    @request_params = params.to_json
    @release_hash = FrontRelease.hash
    haml :index, :layout => :layout
  end

  get '/tmp/pages/*.html' do |page_name|
    haml ('pages/' + page_name).to_sym, :layout => false
  end

  get '/user/balance.json' do
    @current_user.refresh_real_balance!

    { 
      :real_balance => @current_user.real_balance.to_i,
      :game_balance => @current_user.game_balance.to_i,
    }.to_json
  end

end
