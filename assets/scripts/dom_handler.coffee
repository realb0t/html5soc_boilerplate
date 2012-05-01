define [
  'jquery'
], ($, _, Backbone) ->

  handler = (selector, callback) ->
    timer = setInterval () ->
      if $(selector).size() > 0
        clearInterval(timer)
        callback()
    , 
      100

    return null

  return handler