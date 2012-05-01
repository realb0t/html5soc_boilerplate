define [  
  'jquery'
  'underscore'
  'backbone'
  'SynergyHelper'
], ($, _, Backbone, Helpers) =>

  Callback = 
    AfterApi: 
      callbacks: []
      add: (callback) ->
        if FAPI.initialized
          callback()
        else
          Callback.AfterApi.callbacks.push(callback)
      execute: (arguments) ->
        _(Callback.AfterApi.callbacks).map (callback) ->  
          callback.apply(null, arguments) if _.isFunction(callback)

        arguments


    Balance:
      changeCheck: (amount, callback) ->
        delay = 2000
        interval_id = null
        callback = callback || () ->
        
        clear_interval = () ->
          clearInterval(interval_id) if interval_id
        
        set_new_balance = (value) -> $('#balance').text(value)
        
        check = () ->
          user = Synergy.current.account
          $.get Helpers.urlInEnv('/user/balance.json'), (data) -> 
            if user.get('real_balance') != data['real_balance']
              user.set('real_balance', data['real_balance'])
              clear_interval()
              callback()

            return data
        
        interval_id = setInterval(check, delay)

  return Callback
