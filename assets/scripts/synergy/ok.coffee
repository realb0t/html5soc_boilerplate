define [  
  'jquery'
  'underscore'
  'backbone'
  'SynergyProvider'
  'SynergyHelper'
  'SynergyCallbacks'
], ($, _, Backbone, Provider, Helpers, Callbacks) =>


  window.API_callback = (method, result, data) ->
    window.API_callback[method](result, data)
    delete window.API_callback[method]

  class Ok extends Provider

    # map_field
    models_map: 
      user:
        small_image  : 'pic_1'
        middle_image : 'pic_2'
        is_male      : (profile) -> profile.get('gender') != 'female'

    request_fields: 'uid,first_name,last_name,name,gender,birthday,age,locale,location,current_location,current_status,pic_1,pic_2,pic_3,pic_4,url_profile,url_profile_mobile,url_chat,url_chat_mobile';

    friends_per_request: 99

    initialize: () ->
      @without_confirm = true

    init: (callback) ->

      try
        FAPI.Client.initialize();
        Social.info('Try init OK API with', 
          Social.Config.api_server, 
          Social.Config.apiconnection)

        apiServer = Social.Config.api_server
        apiConn = Social.Config.apiconnection

        initialized = () ->
          @dfd.resolveWith(@)

        not_initialized = (error) ->
          @dfd.rejectWith(@)
          
        FAPI.init(apiServer, apiConn, initialized, not_initialized)
      catch e
        @dfd.rejectWith(@)

    after: () ->
      callStack = [
        Callbacks.AfterApi.execute # last
        @accountInit
        @initPermissions
      ]

      args = arguments
      _(callStack).each (func) => func.apply(@, args)

    initPermissions: () ->

    chargeOnBalance: (amount, callback) ->
      API_callback.showPayment = () ->
        Social.log('На баланс зачисленно ' + amounts);

      FAPI.UI.showPayment(
        'Пополнение баланса в приложение'
        'Пополнение баланса в приложение'
        '0'
        Math.ceil(amount)
        null
        null
        'ok'
        'true'
      )
      
      Callbacks.Balance.change_check()


    screenInit: () -> 
      FAPI.UI.setWindowSize(730, $(document.body).height()) if FAPI.initialized

    invite: () ->
      FAPI.UI.showInvite('Отправляйте магические открытки!')

    getInfo: (uids, callback) ->
      request_param = 
        method: 'users.getInfo'
        fields: Ok.request_fields
        uids: _([uids]).flatten().join(',')
        emptyPictures: true 

      return FAPI.Client.call request_param, (status, profiles, error) -> callback(profiles)

    getFriendsUids: (callback) ->
      Social.info('FAPI get friends:');
      FAPI.Client.call { 'method': 'friends.get' }, (status, friends_uids, error) ->
        callback(friends_uids)
      
    getFriends: (callback) ->
      @getFriendsUids(status, friends_uids, error) =>
        @get_info(friends_uids, callback)



    #Notification: class

    confirmParams: (request) ->
      params =  _.extend({
        application_key: SynergyConfig.Env.Ok.fapi_params.application_key
        session_key: SynergtConfig.Env.Ok.fapi_params.session_key
        format: 'JSON'
      }, request)

      return params

    normalize_body: (body) -> 
      body.replace(RegExp('&nbsp;', 'g'), ' ').replace(RegExp('&mdash;', 'g')).replace(/&/g, '')

    confirm_send: (type, confirm_text, request, callback) ->

      if @without_confirm 
        return FAPI.Client.call request, () ->
          callback(true, arguments)

      API_callback.showConfirmation = (state, resig) ->

        if state == 'ok'
          request = _.extend(request, { resig: resig })
          FAPI.Client.call request, () ->
            callback(true, arguments)

        callback(false, null)

      return FAPI.UI.showConfirmation(
        type
        confirm_text
        FAPI.Util.calcSignature(
          @confirmParams(request)
          SynergtConfig.Env.fapi_params.session_secret_key
        )
      )

    notificationsSend: (body, confirm_body, uid, callback) ->
      return callback(false, 'not set message body or confirm body') if !body || !confirm_body

      body = @normalize_body(body)
      body = body.slice(0, 100)
      callback = if _(callback).isFunction() then callback else () -> return false

      return @confirm_send(
        'notifications.send'
        confirm_body
        { 'method': 'notifications.sendSimple', 'text': body, 'uid': uid }
        callback
      )

    streamPublish: (body, confirm_body, uid, callback) ->
      return callback(false, 'not set message body or confirm body') if !body || !confirm_body

      callback = if _(callback).isFunction() then callback else () -> return false
      request = { method: 'stream.publish' }

      if _(body).isObject() && body['message']
        request = _.extend(request, body)
      else
        request = _.extend(request, { 'message': body })

      request.message = @normalize_body(request.message)
      return @confirm_send('stream.publish', confirm_body, request, callback)

    send: (params, callback) ->
      @notificationsSend(params['body'], params['confirm_body'], params['uid'], callback)
    
    publish: (params, callback) ->
      @streamPublish(params['body'], params['confirm_body'], params['uid'], callback)
    
    private: (params, callback) -> @callback()

    protected: (uid, params = {}, callback) ->
      message = paras['message'] || ''
      custom_args = params['requestKey']
      FAPI.UI.showConfirmation(message, { 'custom_args': custom_args })
      API_callback.showConfirmation = (result, data) ->
        callback(result, data)

    subscribe: () ->

    unsubscribe: () ->

  return Ok