define [
  'jquery'
  'underscore'
  'backbone'
], ($, _, Backbone) ->

  class MainMoney extends Backbone.View

    tagName: 'div'
    className: 'popup'

    events: {
      'click .stub': 'onStub'
      'click .buttons .cancel': 'onCancel'
    }

    onStub: (event) -> 
      event.preventDefault()
      event.stopPropagation()

    onCancel: (event) ->
      event.preventDefault()
      event.stopPropagation()
      @hide()

    render: () ->
      $(@el).html('')

    hide: () ->
      $('.popups div').last().show() if $('.popups div').last() > 0
      return super()