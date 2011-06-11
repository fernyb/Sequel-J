# Sequel-J

MySQL database management. An attempt to port "Sequel Pro" over to Cappuccino.

## Requirements For Server

* Ruby 1.9.2
* RubyGems (Sinatra, Bundler)
* MySQL

## Install Gem Dependencies

In the root directory of the server run the following command:

    bundle install

This installs all the Gem Dependencies listed in the gemfile.


## Starting the server

Once you have all the dependencies, You can start the server with the following command:

    RACK_ENV=development shotgun -p 3000

Point your browser to http://localhost:3000/ and you should see the words 'Hello World'

Sequel-J will make request to this server and it does not send SQL.

Once you have the server running you can now open Sequel-J (client/index-debug.html)


## Screencast

When completed a screencast will be available to demonstrate the application.


![Sequel-J](http://github.com/downloads/fernyb/Sequel-J/sequel-j-login.png)

![Sequel-J Content Tab View](http://github.com/downloads/fernyb/Sequel-J/sequel-j-content-tab.png)
