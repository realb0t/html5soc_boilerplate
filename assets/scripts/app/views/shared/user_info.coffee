define [  
  'order!jquery'
  'order!underscore'
  'order!backbone'
  'Plural'
], ($, _, Backbone) ->

  class UserInfo extends Backbone.View
    tagName: 'ul'
    events: {
      'click li a.invite': 'onInvite'
    }

    template: _.template('
    <li>Ваш баланс: <span><%= real_balance %></span> <%= real_balance_title %></li>
    <li><a href="#" class="invite">Приглашай друзей!</a><li>
    ')

    onInvite: (event) ->
      event.preventDefault()
      Synergy.current.invite()

    render: () ->
      model = _(@model.attributes).extend
        real_balance_title: _.plural(@model.get('real_balance'), 'монета', 'монеты', 'монет')

      $(@el).html(@template(model))
      @model.on 'change:real_balance', () => @render()
      $('#header .title .balance').html(@el)

      return @
