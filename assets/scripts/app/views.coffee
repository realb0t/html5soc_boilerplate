define [
  'jquery'
  'underscore'
  'backbone'
  'AppViewsMainPage'
  'AppViewsHelpPage'
  'AppViewsUnsupportPage'
], ($, _, Backbone, MainPage, HelpPage, UnsupportPage) ->

  class Application extends Backbone.View
    el: $('body')

    events: {
      'click nav a.main': 'onMainPage'
      'click nav a.help': 'onHelpPage'
    }
      
    onMainPage: (event) ->
      event.preventDefault()
      Backbone.history.navigate('main', {trigger: true})
      
    onHelpPage: (event) ->
      event.preventDefault()
      Backbone.history.navigate('help', {trigger: true})

    initialize: (@params) ->

    render: () ->
      $('nav').hide() if @params && @params['hide_nav']
      return @


  return {
    Application: Application
    MainPage: MainPage
    HelpPage: HelpPage
    UnsupportPage: UnsupportPage
  }