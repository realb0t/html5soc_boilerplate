define [
  'underscore'
], (_) ->

  _.mixin
    plural: () ->
      ruIndex = (a) ->
        return 1 if ( a % 10 == 1 && a % 100 != 11 )
        return 2 if ( a % 10 >= 2 && a % 10 <= 4 && ( a % 100 < 10 || a % 100 >= 20))
        return 3
      return arguments[ruIndex(arguments[0])]
