define [
  'jquery'
  'underscore'
  'backbone'
  'AppCollections'
  'SynergyHelper'
], ($, _, Backbone, Collections, SynergyHelper) ->

  class CustomModel extends Backbone.Model

  return {
    CustomModel: CustomModel
  }