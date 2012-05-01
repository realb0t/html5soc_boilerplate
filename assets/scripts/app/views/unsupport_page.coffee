define [
  'jquery'
  'underscore'
  'backbone'
  'DomHandler'
  'text!static_tmp/pages/unsupport.html'
], ($, _, Backbone, DomHandler, pageTemplate) ->

  class UnsupportPage extends Backbone.View
    tagName: 'section'
    className: 'page'
    id: 'unsupport_page'

    render: ->
      @$el.html(pageTemplate)
      DomHandler '#unsupport_page', () -> Synergy.current.screenInit()

  return UnsupportPage