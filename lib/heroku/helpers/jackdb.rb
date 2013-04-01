require 'rubygems'
require 'net/http'
require 'net/https'
require 'json'
require 'heroku/command/run'
require "heroku/command/base"
require "heroku/command/pg"
require "heroku/client/heroku_postgresql"
require "heroku/helpers/heroku_postgresql"

module Heroku::Helpers::JackDB
  extend self
  
  def open_link(link)
  	if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/ then
  	  system("start", link)
  	elsif RbConfig::CONFIG['host_os'] =~ /darwin/ then
  	  system("open", link)
  	elsif RbConfig::CONFIG['host_os'] =~ /linux/ then
  	  system("xdg-open", link)
  	end
  end
  
	def gen_datasource_name(name)
	  app_data = api.get_app(app).body
	  return "#{app_data["name"]} - #{name}"
	end

  def open_jackdb(config)    
    jackdb_server = URI("https://cloud.jackdb.com")
    #jackdb_server = URI("http://localhost:8080/jackdb-webapp")
    
    jackdb_server_create_path = "/api/v1/na/directConnect"
    jackdb_server_connect_path = "/home/directConnect"
    
    net = Net::HTTP.new(jackdb_server.host, jackdb_server.port)
    if jackdb_server.scheme == "https"
      net.use_ssl = true
    end

    request = Net::HTTP::Post.new("#{jackdb_server.path}#{jackdb_server_create_path}")
    request.add_field("Content-Type", "application/json")
    request.add_field("Referer", jackdb_server)
    request.body = config.to_json
    
    net.read_timeout = 10
    net.open_timeout = 10

    response = net.start do |http|
      http.request(request)
    end

    result = JSON.parse(response.read_body)
    if result && result['success'] && result['token']
      jackdb_link = "#{jackdb_server}#{jackdb_server_connect_path}?token=#{result['token']}"
      puts "Successfully created JackDB connection token for your data source."
      puts "Your browser should automatically open to JackDB."
      puts "If not use this link:"
      puts ""
      puts "#{jackdb_link}"
      puts ""
      open_link jackdb_link
    else
      puts "Sorry an error occurred opening up JackDB Cloud. If this problem persists please contact support."
    end
  end

  def open_mysql(name, url)    
    uri = URI.parse( url )
    config = {
      :name => gen_datasource_name(name),
      :type => "MYSQL",
      :config => {
        :host => uri.host,
        :port => uri.port || 3306,
        :database => uri.path[1..-1],
        :username => uri.user,
        :password => uri.password,
        :use_ssl => true,
        :validate_ssl_cert => false
      }
    }
    open_jackdb(config)
  end

  # Tries a series of config variable names and returns the value
  # of the first that successfully parses as a URI and matches
  # the provided scheme.
  def resolve_config_var_uri(scheme, *names)
  	names.each do |name|
	   val = app_config_vars[name]
	    begin
	      uri = URI.parse(val)
	      if uri.scheme == scheme
	        return val
	      end
	    rescue
	    end
	  end
	  return nil
	end
end