define [
  'order!vendor/underscore/underscore_src'
  'order!vendor/backbone/backbone_src'
  #'order!vendor/paper/paper_nightly'
], () ->

  #paper.install(window)
  #paper.setup('main_canvas')
  #paper_scope = paper

  return {
    _: _.noConflict()
    Backbone: Backbone.noConflict()
    #paper: paper_scope
  }