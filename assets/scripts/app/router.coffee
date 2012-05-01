define [
  'jquery'
  'underscore'
  'backbone'
  'AppViews'
  'AppModels'
  'SynergyHelper'
], ($, _, Backbone, Views, Models, SynergyHelper) ->

  Router = { current_page: null }

  class Router.Unsupport extends Backbone.Router

    routes: '*action': 'showUnsupportPage'

    showUnsupportPage: ->
      Router.current_page = new Views.UnsupportPage()
      Router.current_page.render()
    

  class Router.Support extends Backbone.Router

    routes:
      'main' : 'showMain'
      'help' : 'showHelp'
      '*actions' : 'showMain'

    preReset: ->
      Synergy.current.account.off('refresh_real_balance')

    showMain:  ->
      AccessLog.pushWithEnv('MainPage')
      @page = new Views.MainPage() 
      $('section.pages').html(@page.render().el)

    showHelp: ->
      AccessLog.pushWithEnv('HelpPage')
      @page = new Views.HelpPage() 
      $('section.pages').html(@page.render().el)

  return Router