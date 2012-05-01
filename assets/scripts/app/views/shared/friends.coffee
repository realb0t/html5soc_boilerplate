define [  
  'jquery'
  'underscore'
  'backbone'
  'text!static_tmp/shared/friend.html'
], ($, _, Backbone, partialTemplate) ->

  class Friend extends Backbone.View

    tagName: 'div'
    className: 'friend'

    events: {
      'click .friend_avatar': 'selectFriend'
    }

    selectFriend: (event) ->
      event.preventDefault()
      event.stopPropagation()
      $('.friend_list .friend').removeClass('selected')
      @$el.addClass('selected')
      @model.trigger('select', @model)

    template: _.template(partialTemplate)
    render: () ->
      $(@el).html(@template(@model.attributes))
      $(@el).attr('data-uid', @model.get('uid'))
      return @


  class List extends Backbone.View

    tagName: 'div'
    className: 'friend_list'

    render: () ->

      @model.each (friend) =>
        friendView = new Friend
          model: friend
          id: 'friend_' + friend.get('uid')
        friendView.render()
        $(@el).append(friendView.el)

      return @

  return {
    Friend: Friend
    List: List
  }