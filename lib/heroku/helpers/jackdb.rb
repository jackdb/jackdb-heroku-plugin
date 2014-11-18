require 'rubygems'
require 'net/http'
require 'net/https'
require 'heroku/command/run'
require "heroku/command/base"
require "heroku/command/pg"
require "heroku/client/heroku_postgresql"
require "heroku/helpers/heroku_postgresql"

module Heroku::Helpers::JackDB
  extend self

  def plugin_version
    return "2.0.0"
  end
  
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
    jackdb_server = URI("https://app.jackdb.com")
    jackdb_server_create_path = "/api/v1/direct-connect/setup"
    jackdb_server_connect_path = "/data-source/direct-connect"
    
    net = Net::HTTP.new(jackdb_server.host, jackdb_server.port)
    if jackdb_server.scheme == "https"
      net.use_ssl = true
    end

    # Add the plugin version to the config
    config['plugin_version'] = plugin_version

    request = Net::HTTP::Post.new("#{jackdb_server.path}#{jackdb_server_create_path}")
    request.add_field("Content-Type", "application/json")
    request.add_field("Referer", jackdb_server)
    request.add_field("User-Agent", "JackDB Heroku Plugin v#{plugin_version()}")
    request.body = JackDB::OkJson::encode(config)
    
    net.read_timeout = 10
    net.open_timeout = 10

    response = net.start do |http|
      http.request(request)
    end

    response = JackDB::OkJson::decode(response.read_body)
    if response && response['success']
      result = response['result']
      id = result['id']
      token = result['token']
      jackdb_link = "#{jackdb_server}#{jackdb_server_connect_path}?id=#{id}&token=#{token}"
      puts "Successfully created JackDB connection token for your data source."
      puts "Your browser should automatically open to JackDB."
      puts "If not use this link:"
      puts ""
      puts "#{jackdb_link}"
      puts ""
      open_link jackdb_link
    else
      puts "Sorry an error occurred opening up JackDB. If this problem persists please try updating your plugin to the latest version or contact support."
      if response && response['error'] && response['error']['message']
        puts "Error: " + response['error']['message']
      end
    end
  end

  def open_postgres(name, uri)    
    if uri == nil
      return false
    end
    if( uri.scheme != "postgres" ) 
      raise "URI is not a PostgreSQL datasource URL: #{uri}"
    end
    config = {
      'name' => gen_datasource_name(name),
      'type' => "postgresql",
      'config' => {
        'host' => uri.host,
        'port' => uri.port || 5432,
        'database' => uri.path[1..-1],
        'username' => uri.user,
        'password' => uri.password,
        'ssl' => true
      }
    }
    open_jackdb(config)
    return true
  end

  def open_mysql(name, uri)
    if uri == nil
      return false
    end
    if( uri.scheme != "mysql" ) 
      raise "URI is not a MySQL datasource URL: #{uri}"
    end
    config = {
      'name' => gen_datasource_name(name),
      'type' => "mysql",
      'config' => {
        'host' => uri.host,
        'port' => uri.port || 3306,
        'database' => uri.path[1..-1],
        'username' => uri.user,
        'password' => uri.password,
        'ssl' => true,
      }
    }
    open_jackdb(config)
    return true
  end

  def open_oracle(name, uri)    
    if uri == nil
      return false
    end
    if( uri.scheme != "oracle" ) 
      raise "URI is not a Oracle datasource URL: #{uri}"
    end
    config = {
      'name' => gen_datasource_name(name),
      'type' => "oracle",
      'config' => {
        'host' => uri.host,
        'port' => uri.port || 1521,
        'database' => uri.path[1..-1],
        'username' => uri.user,
        'password' => uri.password,
      }
    }
    open_jackdb(config)
    return true
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
          puts "Found a valid URL for scheme '#{scheme}':"
          puts "  #{name} => #{val}"
          return uri
        end
      rescue
      end
    end
    return nil
  end

  def get_config_vars(config_var)
    config_vars = []
    if config_var == nil
      # Use the standard list of config variable values
      config_vars.push "DATABASE_URL"
      config_vars.push "POSTGRESQL_DATABASE_URL"
      config_vars.push *app_config_vars.keys.grep(%r{HEROKU_POSTGRESQL_}i)
      config_vars.push "MYSQL_DATABASE_URL"
      config_vars.push "ORACLE_DATABASE_URL"
      # After primary list try anything that looks like a URL:
      config_vars.push *app_config_vars.keys.grep(%r{_URL}i)
    else
      # Put the value itself first to make it's specificity highest
      config_vars.push config_var
      # Use the config var to get all related config variables
      config_vars.push *app_config_vars.keys.grep(%r{#{ config_var }}i)
    end
    return config_vars
  end

  def app_config_vars
    app_name = app rescue nil    
    @app_config_vars ||= api.get_config_vars(app_name).body
  end
end
