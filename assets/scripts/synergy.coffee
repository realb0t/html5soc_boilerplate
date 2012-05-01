define [  
  'jquery'
  'underscore'
  'backbone'
  'SynergyProducer'
  'SynergyVk'
  'SynergyOk'
], ($, _, Backbone, Producer, Vk, Ok) =>

  root = @
  preSynergy = root.Synergy
  Synergy = exports ? root.Synergy = {}
  Synergy.noConflict = () ->
    root.Synergy = preSynergy
    return @

  Synergy.init = 
    vk: _.once (options, callback) ->
      provider = new Vk()
      producer = new Producer(provider, options).init
        success: callback
        failure: callback

    ok: _.once (options, callback) ->
      provider = new Ok()
      producer = new Producer(provider, options).init
        success: callback
        failure: callback

  Synergy.current = null

  return Synergy
