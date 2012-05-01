define [  
  'jquery'
  'underscore'
  'backbone'
  'SynergyProvider'
  'SynergyHelper'
  'SynergyCallbacks'
], ($, _, Backbone, Provider, Helpers, Callbacks) =>

  class Vk extends Provider

    models_map: 
      user:
        small_image  : 'photo',
        middle_image : 'photo_medium',
        gender       : 'sex'
        is_male      : (profile) -> profile.get('sex') == 2

    request_fields: 'uid,first_name,last_name,nickname,sex,birthdate,city,country,timezone,photo,photo_medium,photo_big,domain,has_mobile,rate,contacts,education'

    friends_per_request: 999

    init: () -> 
      try
        VK.init () =>
          @call "setLocation", window.location.pathname
          @subscribe 'onLocationChanged', (location) ->
            if _.isFunction(location.strip)
              if window.location.pathname != location && location.strip() != ''
                window.location = location 

          return @dfd.resolveWith(@)
      catch e
        #console.error('error', e)
        @dfd.rejectWith(@)

    after: () ->

      callStack = [
        #Callback.AfterApi.execute # last
        @accountInit
        #@screenInit
        @initPermissions
      ]

      args = arguments
      _(callStack).each (func) => func.apply(@, args)

    initPermissions: () ->
      permissions = 2 + 1 + 512 + 8192
      @applySettings(SynergyConfig.User.uid, permissions)

    applySettings: (uid, permissions) ->
      @deferredCall "getUserSettings", { uid: uid }, (result) =>
        currentPermissions = result.response || 0
        #console.log('permission', currentPermissions, permissions, currentPermissions & permissions)
        unless currentPermissions & permissions
          @call "showSettingsBox", permissions

    screenInit: (element, delta) ->
      element ||= document.body
      delta ||= 0
      @call("resizeWindow", 730, $(element).height() + delta)

    chargeOnBalance: (amount, callbacks) ->
      #amount = amount / (Config.rate || 6)
      readyCallback = callbacks['ready'] || () ->
      completeCallback = callbacks['complete'] || () ->
      @subscribe 'onBalanceChanged', () =>
        Callbacks.Balance.changeCheck(amount, completeCallback)
        @unsubscribe "onBalanceChanged", arguments.callee
        readyCallback()

      @call("showPaymentBox", 0+amount)

    invite: () ->
      #url = Helpers.social_path_prefix + '/user/as_inviter'
      #$.post url, (result) => @call("showInviteBox")
      @call("showInviteBox")

    ## User

    getInfo: (uids, callback) ->
      request_param =
        'fields': @request_fields 
        'uids': _([uids]).flatten().join(',')
      
      @deferredCall 'getProfiles', request_param, (result) ->
        return callback(result.response) if result.response
        callback([])

    getFriendUids: (callback) ->
      @deferredCall 'friends.get', uid: @account.get('uid'), 
        (result) ->
          #console.log('friends.get', result)
          if result.response
            uids = _(result.response).map (uid) -> uid + ''
            callback(uids) 
          else 
            callback([])

    # Notification
    send: (params, callback) -> callback()

    # отправка простого нотифая
    publish: (params, callback) ->
      @deferredCall 'wall.post', 
        { 'message': params['body']['message'] }, 
        (result) ->
          callback(result)

    # запись в ленту
    private: () ->
      callback()
      
    # отправка сообщения
    protected: (uid, params = {}, callback) ->
      messages = params['message'] || ''
      requestKey = params['requestKey']
      callback ?= () ->

      @call "showRequestBox", uid, messages, requestKey
      #onRequestCancel, onRequestFail
      @subscribe 'onRequestSuccess', () => 
        callback()
        @unsubscribe "onRequestSuccess", arguments.callee

    ## Common methods

    call: () ->
      #console.log('VK call', arguments[0])
      VK.callMethod.apply(VK, arguments)

    deferredCall: (cmd, params, callback) -> 
      #console.log('VK def.call', [cmd, params])
      VK.api(cmd, params, callback)

    subscribe: (event, callback) ->
      VK.addCallback event, callback

    unsubscribe: (event, callback) ->
      VK.removeCallback event, callback

  return Vk
