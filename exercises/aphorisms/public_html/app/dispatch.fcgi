#!/usr/bin/ruby

require 'rubygems'
require 'rack'

fastcgi_log = File.open("fastcgi.log", "a")
STDOUT.reopen fastcgi_log
STDERR.reopen fastcgi_log
STDOUT.sync = true

module Rack
	class Request
		def path_info
			@env["REDIRECT_URL"].to_s
		end

		def path_info=(s)
			@env["REDIRECT_URL"] = s.to_s
		end
  end
end

load 'app.rb'

builder = Rack::Builder.new do
	map '/' do
		run Aphorisms.new
	end
end

Rack::Handler::FastCGI.run(builder)
