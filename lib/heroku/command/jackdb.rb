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

  # jackdb:pg [CONFIG_VAR]
  #
  # Opens a Postgres database in JackDB
  #
  # Connection information is pulled from the first valid value of DATABASE_URL, POSTGRESQL_DATABASE_URL, or from a matching database alias (e.g. WHITE, COPPER).
  def pg
    config_var = shift_argument
    config_vars = get_config_vars(config_var)
    uri = resolve_config_var_uri("postgres", *config_vars)
    if !open_postgres("PostgreSQL", uri)
      puts "Could not find a valid PostgreSQL database URL to connect to."
    end
  end

  # jackdb:mysql [CONFIG_VAR]
  #
  # Opens a MySQL database in JackDB
  #
  # Connection information is pulled from the first valid value of DATABASE_URL or MYSQL_DATABASE_URL
  def mysql
    config_var = shift_argument
    config_vars = get_config_vars(config_var)
    uri = resolve_config_var_uri("mysql", *config_vars)
    if !open_mysql("MySQL", uri)
      puts "Could not find a valid MySQL database URL to connect to."
    end
  end

  # jackdb:oracle [CONFIG_VAR]
  #
  # Opens an Oracle database in JackDB
  #
  # Connection information is pulled from the first valid value of DATABASE_URL or ORACLE_DATABASE_URL.
  # Database URLs should be of the form: oracle://<username>:<password>@<hostname>[:<port>]/<service-name>
  #
  # Example: oracle://myuser:mypass@myhost.example.org:1521/myservice_name
  def oracle
    config_var = shift_argument
    config_vars = get_config_vars(config_var)
    uri = resolve_config_var_uri("oracle", *config_vars)
    if !open_oracle("Oracle", uri)
      puts "Could not find a valid Oracle database URL to connect to."
    end
  end

  # jackdb:cleardb
  #
  # Opens a ClearDB MySQL database in JackDB
  #
  # Connection information is pulled from CLEARDB_DATABASE_URL
  def cleardb
    uri = resolve_config_var_uri("mysql", "CLEARDB_DATABASE_URL")
    if !open_mysql("ClearDB MySQL", uri)
      puts "Could not find a valid ClearDB MySQL database URL to connect to."
    end
  end

  # jackdb [filter]
  #
  # Open a database in JackDB
  #
  # This will search through your app config for the first valid database url and try to connect to it.
  # The search order for databases is PostgreSQL, then MySQL, then Oracle.
  # 
  # If you have more than one database then use one of the "jackdb:" commands to connect to a specific type of database.
  # You can also filter the config variables that are matched by specifying a filter as an argument. Filters are case insensitive.
  def index
    config_var = shift_argument
    config_vars = get_config_vars(config_var)

    if open_postgres("PostgreSQL", resolve_config_var_uri("postgres", *config_vars))
      return
    elsif open_mysql("MySQL", resolve_config_var_uri("mysql", *config_vars))
      return
    elsif open_oracle("Oracle", resolve_config_var_uri("oracle", *config_vars))
      return
    else
      puts "Sorry! No valid database URL was found."
    end
  end
end
