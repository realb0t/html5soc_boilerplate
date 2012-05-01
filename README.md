HTML5 SocialApplication Boilerplate
====================

Sinatra + Mongoid + BackboneJS + RequireJS + JQuery
Ready deploy to Heroku.

Install:
---------------------

Need ruby 1.9.2

	$ git clone git@github.com:realb0t/html5soc_boilerplate.git
	$ cd html5soc_boilerplate
    $ bundle install

Run:
---------------------

Run server:
	
    $ rackup

Open browser and load http://localhost:9292/vk or Open browser and load http://localhost:9292/odkl

Console
----------------------

	$ irb -r ./console.rb

Include:

* Social (Backend Social API wrapper)
* Synergy (Frontend Social API wrapper)

Deploy
-----------------------

Add heroku repository path:

	$ git remote add heroku <HEROKU REPO PATH>

Create release:

	$ rake deploy:front
	$ git add .
	$ git commit -am 'release_XXXX_XX_XX_XXXX'

Deploy on Heroku:

	$ git push heroku master