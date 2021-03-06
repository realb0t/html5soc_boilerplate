require.config
  urlArgs: "bust=" + (new Date()).getTime()
  waitSeconds: 50
  paths:

    # vendors
    'loader': 'vendor/loader'
    'jquery': 'vendor/jquery/jquery_src'
    'json2': 'vendor/json2/json2_src'
    'modernizr': 'vendor/modernizr/modernizr_src'
    'underscore': 'vendor/underscore/underscore'
    'backbone': 'vendor/backbone/backbone'

    # plugins
    'text': 'vendor/require/text'
    'order': 'vendor/require/order'
    'DomReady': 'vendor/require/dom_ready'

    'tmp': '../tmp'
    'static_tmp': '../static_tmp'

    'App': 'app'
    'AppBus': 'app/bus'
    'AppCollections': 'app/collections'
    'AppModels': 'app/models'
    'AppViews': 'app/views'
    'AppViewsHelpPage': 'app/views/help_page'
    'AppViewsMainPage': 'app/views/main_page'
    'AppViewsUnsupportPage': 'app/views/unsupport_page'
    'AppViewsSharedMainPopup': 'app/views/shared/main_popup'
    'AppViewsSharedSendPopup': 'app/views/shared/example_popup'
    'AppRouter': 'app/router'

    # appliation
    'Detector': 'detector'
    'DomHandler': 'dom_handler'
    'Plural': 'plural'

    # Synergy
    'Synergy': 'synergy'
    'SynergyConfig': '/vk/synergy_config'
    'SynergyProvider': 'synergy/provider'
    'SynergyProducer': 'synergy/producer'
    'SynergyVk': 'synergy/vk'
    'SynergyOk': 'synergy/ok'
    'SynergyHelper': 'synergy/helpers'
    'SynergyCallbacks': 'synergy/callbacks'
    'SynergyModels': 'synergy/models'

require [
  'DomReady'
  'App'
], (domReady, FireFlies) -> 
  domReady.withResources () -> FireFlies.initialize()
