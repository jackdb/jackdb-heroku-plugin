require 'heroku/command/run'
require "heroku/command/base"
require "heroku/command/pg"
require "heroku/client/heroku_postgresql"
require "heroku/helpers/heroku_postgresql"
require "heroku/helpers/jackdb"
require "vendor/jackdb/okjson"

# open database in JackDB
class Heroku::Command::JackDB < Heroku::Command::Run
  include Heroku::Helpers::HerokuPostgresql
  include Heroku::Helpers::JackDB

  # jackdb:mysql [CONFIG_VAR]
  #
  # Opens a MySQL database in JackDB
  #
  # Connection information is pulled from the first valid value of DATABASE, MYSQL_DATABASE_URL, or DATABASE_URL matching a mysql database URI
  def mysql(config_var = nil)
    url = resolve_config_var_uri("mysql", config_var, "MYSQL_DATABASE_URL", "DATABASE_URL", "XEROUND_DATABASE_URL", "CLEARDB_DATABASE_URL")
    open_mysql("MySQL", url)
  end

  # jackdb:xeround
  #
  # Opens a Xeround MySQL database in JackDB
  #
  # Connection information is pulled from XEROUND_DATABASE_URL
  def xeround
    url = app_config_vars["XEROUND_DATABASE_URL"]
    name = "Xeround MySQL"
    open_mysql(name, url)
  end

  # jackdb:cleardb
  #
  # Opens a ClearDB MySQL database in JackDB
  #
  # Connection information is pulled from XEROUND_DATABASE_URL
  def cleardb
    url = app_config_vars["CLEARDB_DATABASE_URL"]
    name = "ClearDB MySQL"
    open_mysql(name, url)
  end

  # jackdb:pg [DATABASE]
  #
  # Opens a PostgreSQL database in JackDB
  #
  # Defaults to DATABASE_URL databases if no DATABASE is specified
  def pg
    uri = URI.parse( hpg_resolve(shift_argument, "DATABASE_URL").url )
    config = {
      'name' => gen_datasource_name("PostgreSQL"),
      'type' => "POSTGRESQL",
      'config' => {
        'host' => uri.host,
        'port' => uri.port || 5432,
        'database' => uri.path[1..-1],
        'username' => uri.user,
        'password' => uri.password,
        'use_ssl' => true,
        'validate_ssl_cert' => false
      }
    }
    open_jackdb(config)
  end

  # jackdb
  #
  # Open a database in JackDB
  #
  # This will search through your app config for the valid database url and try to connect to it.
  # If you have more than one database then use one of the "jackdb:" commands to connect to a specific one.
  def index
    begin
      pg()
      return
    rescue
    end
    begin
      mysql()
      return
    rescue
    end
    puts "Could not find a database to connect to :("
  end
end
