define [], () ->

  Detector = 

    canvas: () ->
      return !! window.CanvasRenderingContext2D

    webgl: () -> 
      try 
        return (!! window.WebGLRenderingContext) && (!! document.createElement('canvas').getContext('experimental-webgl'))
      catch e
        return false

    workers: () ->
      return !! window.Worker

    fileapi: () ->
      window.File && window.FileReader && window.FileList && window.Blob

    support: (result, callbacks) ->
      if @canvas()
        callbacks['success']() if callbacks['success']
      else
        callbacks['failure']() if callbacks['failure']

    supportContext2d: (callbacks) -> @support @canvas(), callbacks
    supportContext3d: (callbacks) -> @support @webgl(), callbacks
    supportWorkers: (callbacks) -> @support @workers(), callbacks
    supportFileApi: (callbacks) -> @support @fileapi(), callbacks

  return Detector
      