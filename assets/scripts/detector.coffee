define [ 
  'modernizr' 
], () ->

  Detector = 

    context2d: (callbacks) ->
      if Modernizr.canvas
        callbacks['success']() if callbacks['success']
      else
        callbacks['failure']() if callbacks['failure']

    context3d: (callbacks) ->
      if Modernizr.webgl
        callbacks['success']() if callbacks['success']
      else
        callbacks['failure']() if callbacks['failure']

  return Detector
      