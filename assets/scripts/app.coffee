define [  
  'jquery'
  'underscore'
  'backbone'
  'AppRouter'
  'AppViews'
  'Detector'
  'Synergy'
], ($, _, Backbone, Routers, Views, Detector, Synergy) ->

  root = @
  root.socContext = {}

  return {

    version: '1.0 betta'

    initialize: _.once () -> 

      Synergy.init[SynergyConfig.Env.type] {}, () ->
        Synergy.current = @
        
        $('#preloader').animate { opacity: 0 }, 700, () -> $('#preloader').hide()

        Detector.supportContext3d
          success: () -> AccessLog.pushWithEnv('Context3dSupport')
          failure: () -> AccessLog.pushWithEnv('Context3dUnsupport')

        Detector.supportContext2d
          success: () ->
              AccessLog.pushWithEnv('Context2dSupport')
              router = new Routers.Support() 
              view = new Views.Application
              Backbone.history.start()
              view.render()
          failure: () ->
              AccessLog.pushWithEnv('Context2dUnsupport')
              router = new Routers.Unsupport()
              view = new Views.Application hide_nav: true 
              Backbone.history.start()
              view.render()
  }
