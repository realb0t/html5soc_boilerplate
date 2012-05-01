define [  
  'jquery'
  'underscore'
  'backbone'
], ($, _, Backbone) =>

  class Producer

    constructor: (@provider, @options = {}) ->
      @beforeUser = @options['before'] || () -> #console.log('user before')
      @afterUser = @options['after'] || () -> #console.log('user after')
      @failUser = @options['fail'] || () -> #console.log('user error')
      _beforeDfd = $.Deferred()
      @afterDfd = _afterDfd = $.Deferred()
      @initDfd = $.Deferred()

      @before = _.compose(
        () => _beforeDfd.resolveWith(@provider)
        @provider.before
        @beforeUser
      )

      @after = _.compose(
        () => _afterDfd.resolveWith(@provider)
        @afterUser
        @provider.after
      )

      $.when(_beforeDfd).done () => @provider.init()
      $.when(@provider.dfd).done(@after).fail(@after) 


    init: (options) ->
      options ?= @options
      options['success'] ?= () -> #console.log('success')
      options['failure'] ?= () -> #console.log('failure')

      process = _.once () =>
        callback ?= () ->
        @before(@)
        $.when(@afterDfd)
          .done(options['success'])
          .fail(options['failure'])

        return @

      return process()

    isSuccessInit: () ->
      @provider.dfd.isResolved() && !@provider.dfd.isRejected()

    isFailureInit: () ->
      !@provider.dfd.isResolved() && @provider.dfd.isRejected()

  return Producer
