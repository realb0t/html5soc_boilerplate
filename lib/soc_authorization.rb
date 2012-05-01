# Проверка того что аутентифицированный пользователь социальной сети 
# имеет права на ресурс пользователя в системе и если таких прав нет, то они создаются

module SocAuthorization

  module Exception 
    class JSON < StandardError
    end

    class Common < StandardError
    end
  end

  def soc_params
    unless @soc_params
      case @social_type
      when :ok
        begin
          @soc_params = {
            :social_type_id => @social_type_id,
            :social_type => @social_type,
            :social_prefix => @social_prefix,
            :uid => params[:logged_user_id] || 123123123123,
            :session_key => params[:session_key],
            :auth_sig => params[:auth_sig],
            :apiconnection => params[:apiconnection],
            :fapi_request => Rack::Utils.build_nested_query(params),
            :session_secret_key => params[:session_secret_key]
          }
        end
      when :vk
        begin
          @soc_params = {
            :social_type_id => @social_type_id,
            :social_type => @social_type,
            :social_prefix => @social_prefix,
            :uid => params[:viewer_id] || 123123123123,
            :api_url => params[:viewer_id],
            :api_id => params[:api_id],
            :user_id => params[:user_id],
            :sid => params[:sid],
            :secret => params[:secret],
            :group_id => params[:group_id],
            :viewer_id => params[:viewer_id],
            :is_app_user => params[:is_app_user],
            :viewer_type => params[:viewer_type],
            :auth_key => params[:auth_key],
            :language => params[:language],
            :api_result => params[:api_result],
            :api_settings => params[:api_settings],
            :referrer => params[:referrer],
            :access_token => params[:access_token],
            :request_key => params[:request_key], # showRequestBox
            :request_id => params[:request_id] # showRequestBox
          }
        end
      else
        raise 'Can\'t find social type'
      end
    end

    @soc_params
  end

  def authorization!(exception_klass = SocAuthorization::Exception::Common)
    if params['social_env']
      Social::Env.init(params) # params['social_env'] => { 'prefix' 'type' 'id' }
      session['social_type_id'] = Social::Env.id || 1
      @social_type_id = Social::Env.id
      @social_type = Social::Env.type
      @social_prefix = Social::Env.prefix
    end

    @remember_token = session['remember_token'] || params['remember_token']

    unless @remember_token

      begin
        @current_user = User.find_or_create_by_uid(soc_params[:uid])
        @remember_token = @current_user.remember_token
        session['remember_token'] = @remember_token
      rescue => e
        raise exception_klass.new('Can\'t authorization because ' + e.message + "\n" + e.backtrace.inspect)
      end
    else
      begin
        @current_user = User.find_by_remember_token(@remember_token)
        @social_type_id = @current_user.social_type_id
      rescue => e
        raise exception_klass.new('Can\'t authorization because: ' + e.message + "\n" + e.backtrace.inspect)
      end
    end

    @uid = @current_user.uid
    @current_user.try_update!
    @current_user.soc_params = soc_params

  end

end