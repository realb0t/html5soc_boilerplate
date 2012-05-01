define [  
  'jquery'
  'underscore'
  'backbone'
  'SynergyModels'
  'SynergyHelper'
], ($, _, Backbone, Models, Helper) =>

  class Provider

    constructor: (config) -> 
      @dfd = $.Deferred() # Ожидающий инициализации апи
      @dfdAccount = $.Deferred()
      @dfdFriends = $.Deferred() # Ожидающий подгрузки друзей

    before: () -> #console.log('provider default before')
    init: () -> @dfd.resolve()
    after: () -> #console.log('provider default after')
    
    # Простой запуск команды
    call: (cmd, params) ->

    # Запуск команды с каллбеком
    deferredCall: (cmd, params, callback) -> callback()

    # Подписка на событие
    subscribe: (event, callback) -> callback()

    # Отписаться от события
    unsubscribe: (event, callback) -> callback()

    # Инициализация аккаунта
    accountInit: () ->
      unless @account
        @account = new Models.Profile(@userFieldMapping(SynergyConfig.User.attributes))
        #console.log('try fetch', @dfd.isResolved(), @dfd.isRejected())
        @dfd.isResolved()

        $.when(@dfd)
          .done(@fetchSocialFriends)
          .fail(@fetchFakeFriends)
      else
        throw 'account already inited'

      return @account

    # Мапим поля пользователя в соц.сети с полями модели пользователя (на уровне входного хеша)
    userFieldMapping: (profile) ->
      _(@models_map.user).each (fromKey, toKey) =>
        return if _.isFunction(fromKey) || _.isNull(profile[fromKey])
        profile[toKey] = _(profile[fromKey]).clone()
        delete profile[fromKey]
      profile

    # Подгрузка друзей из социалки
    fetchSocialFriends: () ->
      return if @dfdFriends.isResolved()
      @getFriendUids (uids) =>
        #console.log('friends uid', uids)
        @getInfoMulti uids, (profiles) =>
          #console.log('profiles', profiles)
          _(profiles).each (profile) => 
            friend = new Models.Friend(@userFieldMapping(profile))
            @account.friends.add(friend)

          @dfdFriends.resolve()

    # Подгрузка друзей из 
    fetchFakeFriends: () ->
      return if @dfdFriends.isResolved()
      @account.friends.fetch
        success: () => @dfdFriends.resolve()

    # Возвращает пррофили с помощью мультизапроса
    getInfoMulti: (uids, callback) ->
      
      multi_results = []
      request_uids = Helper.eachSlice(uids, @friends_per_request)
      
      request = (uids, collectResultCallback) =>
        @getInfo uids, (profiles) ->
          multi_results.push(profiles);
          return collectResultCallback(multi_results);
      
      collectResult = _.after request_uids.length, (result) ->
        profiles = _(result).chain().flatten().compact().sortBy((profile) -> profile['uid']).value()
        callback(profiles)
      
      _(request_uids).each (uids) -> request(uids, collectResult)


  return Provider
