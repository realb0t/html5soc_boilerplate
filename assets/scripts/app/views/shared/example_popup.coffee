define [
  'jquery'
  'underscore'
  'backbone'
  'AppViewsSharedMainPopup'
  'text!static_tmp/shared/example_popup.html'
], ($, _, Backbone, MainPopup, partialTemplate) ->

  # @model: Card
  class ExamplePopup extends MainPopup
    id: 'example_popup'

    events: {
      'click .stub': 'onStub'
      'click .buttons .cancel': 'onCancel'
    }

    onStub: (event) -> 
      event.preventDefault()
      event.stopPropagation()

    template: _.template(partialTemplate)
    render: () ->
      @$el.html(@template())
      return @