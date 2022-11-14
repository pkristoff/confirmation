# This file is used by Rack-based servers to start the application.
# https://stackoverflow.com/questions/3973806/heroku-app-fails-to-start-require-no-such-file-to-load-sinatratestapp-l

require ::File.expand_path('../config/environment/.', __FILE__)
run Rails.application
