define [
  'order!jquery'
  'order!underscore'
  'order!backbone'
  'DomHandler'
  'text!static_tmp/pages/main.html'
], ($, _, Backbone, DomHandler, mainPageTemplate) ->

  class MainPage extends Backbone.View
    tagName: 'section'
    className: 'page'
    id: 'main_page'

    render: -> 
      @$el.html(mainPageTemplate)
      DomHandler '#main_page', () -> Synergy.current.screenInit()
      return @

  return MainPage