# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration
Running in Docker
When running in a docker container, ensure that you include an environments (*.env) file containing the local environment variables required by the application.

* Database creation
Development environment:
Create database: rails db:create
Update database tables: rails db:migrate

Production environment:
To run in rails produciton environment, you need to set the local env variables to include the secret key and other paramaters.  Also, all initialisaiton commands must be prefixed with RAILS_ENV=production, for example "RAILS_ENV=produciton rails db:create"

* Database initialization
Once applicaiton is successfully loading, visit the web page and create the first user account and log in.  The home page /www.mydomain.com/[year]/home will provide a number of steps to upgrade the initial account to admin status followed by a series of DB initialisation steps.  These steps have to be followed for each season.

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions
To start the application running in a docker container, run:

  docker-compose up -d --build

* ...
