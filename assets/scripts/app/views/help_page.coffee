define [
  'jquery'
  'underscore'
  'backbone'
  'DomHandler'
  'text!static_tmp/pages/help.html'
], ($, _, Backbone, DomHandler, pageTemplate) ->

  class HelpPage extends Backbone.View
    tagName: 'section'
    className: 'page'
    id: 'help_page'

    render: ->
      @$el.html(pageTemplate)
      Synergy.current.screenInit(null, 1000)
      return @

  return HelpPage