Confirmation
================
v0.1
Features:
* devise implementation for candidate & admin
* Home page
* About page
* Admin:
  * login
  * creation
  * reset password
  * edit account
  * cancel account
  * list of Admins
* Candidate:
  * login
  * creation
  * reset password
  * edit account
  * cancel account
  
================

[Confirmation github](https://github.com/pkristoff/confirmation)

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

This application was generated with the [rails_apps_composer](https://github.com/RailsApps/rails_apps_composer) gem
provided by the [RailsApps Project](http://railsapps.github.io/).

Rails Composer is supported by developers who purchase our RailsApps tutorials.

Create a file in config named local_env.yml
* EMAIL_PROVIDER_ADDRESS: ''
* EMAIL_PROVIDER_USERNAME: ''
* EMAIL_PROVIDER_PASSWORD: ''

Problems? Issues?
-----------

Need help? Ask on Stack Overflow with the tag 'railsapps.'

Your application contains diagnostics in the README file. Please provide a copy of the README file when reporting any issues.

If the application doesn't work as expected, please [report an issue](https://github.com/RailsApps/rails_apps_composer/issues)
and include the diagnostics.

Ruby on Rails
-------------

This application requires:

- [Ruby 2.3.0](http://ruby-doc.org/core-2.3.0/)
- [Rails 4.2.5.1](http://guides.rubyonrails.org/) - actually v4.2.6

* Learn more about [Installing Rails](http://railsapps.github.io/installing-rails.html).
* Learn more about [Associatiions](http://guides.rubyonrails.org/association_basics.html).
* Learn more about [Heroku] (https://devcenter.heroku.com/articles/getting-started-with-rails4).
* Learn more about [Heroku Assets] (https://devcenter.heroku.com/articles/rails-asset-pipeline).
* Learn more about [Capybara] (http://www.rubydoc.info/github/jnicklas/capybara/Capybara/).
* Learn more about [ActiveRecord] (http://api.rubyonrails.org/classes/ActiveRecord/).
* Learn more about [file upload] (http://ryan.endacott.me/2014/06/10/rails-file-upload.html,
                                    http://mattberther.com/2007/10/19/uploading-files-to-a-database-using-rails).
* Learn more about [Migration] (http://guides.rubyonrails.org/active_record_migrations.htm).
  * db:migrate runs (single) migrations that have not run yet.
  * db:create creates the database
  * db:drop deletes the database
  * db:schema:load creates tables and columns within the (existing) database following schema.rb
  * db:setup does db:create, db:schema:load, db:seed
  * db:reset does db:drop, db:setup
* Learn more about [MD-markdown] (https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet).
* Gmail mailing do https://accounts.google.com/DisplayUnlockCaptcha if gmail is not authenticating.
* hiding passwords http://railsapps.github.io/rails-environment-variables.html
* pdf = http://prawnpdf.org/manual.pdf


Postgres local
---------------
Install postgres
- Login as administrator
- bring up terminal
- brew update
- if postgres is installed
  * brew uninstall postgres 
  * remove rm -r /usr/local/postgres
- brew install postgres
  * if brew postgres post install did not work then do
    * ls -al /usr/local/var/
    * if /usr/local/var/postgres is owned by root then
      * sudo chown -R $(whoami) /usr/local/var/postgres
    * brew postinstall postgres
    * if still having problems with permissions then
        * sudo chmod -R 700 /usr/local/var/postgres
  * try: psql postgres - should take you into postgres console.
    * if not reboot
  * create role for current login
    * CREATE ROLE paulkristoff LOGIN SUPERUSER CREATEROLE CREATEDB REPLICATION BYPASSRLS;
  
Start DB
- login as paulkristoff
- open terminal
- su - administrator
- show-pg-status
  * if running do nothing
  * if not do start-pg
  
Creating DBs.
- open terminal
- cd dev/confirmation
- rake db:setup

SendGrid
-------------------
https://sendgrid.com/docs/API_Reference/api_v3.html
https://github.com/sendgrid/sendgrid-ruby/blob/master/examples/helpers/mail/example.rb#L21

Time consuming bugs
-------------------
- When exporting spreadsheet to excel get the error:
  * An Encoding::CompatibilityError occurred in candidate_imports#export_to_excel:
    * incompatible character encodings: UTF-8 and ASCII-8BIT
    * app/controllers/candidate_imports_controller.rb:52:in `export_to_excel'
  * Solution:  I was putting biary image in worksheet.


Getting Started
---------------

Documentation and Support
-------------------------

Issues
-------------

Similar Projects
----------------

Contributing
------------

Credits
-------

License
-------
