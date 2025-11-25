# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

port = ENV.fetch("PORT") { 8080 }

run Rails.application
Rails.application.load_server
