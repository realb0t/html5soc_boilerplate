define [  
  'jquery'
  'underscore'
  'backbone'
], ($, _, Backbone) =>

  Helpers = 
    eachSlice: (collect, step = 3) ->
      new_collect = []
      new_collect.push(collect.slice(i, i+step)) for i in [0..collect.length] by step
      return new_collect
    urlInEnv: (url) -> 
      '/' + SynergyConfig.Env.prefix + url + '?remember_token=' + SynergyConfig.User.remember_token

  return Helpers
