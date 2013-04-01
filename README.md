# JackDB Heroku Plugin

Extends `heroku` command-line to query and visualize Heroku data sources on [JackDB][JackDB].

## Installation

    $ heroku plugins:install https://github.com/jackdb/jackdb-heroku-plugin.git

## Requirements

The plugin requires the ```json``` ruby gen. If you don't already have it installed you can install it with:

    $ gem install json

## Usage

    $ heroku help jackdb
    Usage: heroku jackdb

	 Open a database in JackDB

	 This will search through your app config for the valid database url and try to connect to it.
	 If you have more than one database then use one of the "jackdb:"" commands to connect to a specific one.

	Additional commands, type "heroku help COMMAND" for more details:

	  jackdb:cleardb             #  Opens a ClearDB MySQL database in JackDB
	  jackdb:mysql [CONFIG_VAR]  #  Opens a MySQL database in JackDB
	  jackdb:pg [DATABASE]       #  Opens a PostgreSQL database in JackDB
	  jackdb:xeround             #  Opens a Xeround MySQL database in JackDB

## Examples

Open up the default database in JackDB (the plugin searches for the first valid database URL):

    $ heroku jackdb

Open up the default PostgreSQL database in JackDB:

    $ heroku jackdb:pg

Open up a specific PostgreSQL database in JackDB:

    $ heroku jackdb:pg COPPER

Open up the default MySQL database in JackDB:

    $ heroku jackdb:mysql

## What types of databases does it support?

The JackDB Heroku plugin currently supports [PostgreSQL][PostgreSQL], [MySQL][MySQL], and [MariaDB][MariaDB]..

JackDB itself supports a number of additional databases. For details [see here][JackDB].

## Can I use this for other types of databases?

We're working on adding support for additional data source types, both relational and NoSQL, to both JackDB itself and to this plugin. [Let us know][Contact] what data source you'd like us to add next.

## Networking/Firewall

The plugin has been tested with [Heroku Postgres][Heroku Postgres], [Xeround MySQL][Xeround MySQL], and [ClearDB MySQL][ClearDB MySQL] and works without any additional setup with all three.

If your database is firewalled you will need to open up the appropriate ports to allow JackDB to access it. For details [see here][JackDB Networking].

## Can I use this with a database running on my local machine or network?

Not yet but we're working on it. At the moment JackDB connects directly to your database so it's not possible to reach databases that are behind a firewall.

## How does it work?

The plugin works in three steps.

First it identifies the database you are connecting to. By default it tries to get the configuration details for the PostgreSQL database in the Heroku config property DATABASE_URL. The other sub commands mainly change where the plugin looks for the database configuration and what type of configuration it looks for.

If it finds a valid configuration it does a POST request to JackDB with the config information of your database. The JackDB server:
 
  1. Generates a unique random id for the request
  1. Generates a random encryption key
  1. Encrypts the data source config information with the key using AES-256-CBC
  1. Saves the encrypted data source config information keyed by the id
  1. Finally it returns back a signed token containing the encryption key and id

The encryption key used to encrypt your data source config is not saved by JackDB. It is only returned back to this plugin in response to the POST request.

Finally the plugin then generates a URL to login directly to JackDB using the token from previous step and opens it as a GET request using your default browser. If you are already logged into JackDB then it will immediately try to connect to your data source. If not then you'll be sent to the login page first (then redirected to the connection). 

In case your browser does not open automatically the link is also printed for manual opening.

No connection attempt is made until after you login and open the page in your browser.

## Do I need to install JackDB?

No. JackDB works entirely in your web browser.

## Is it secure?

All network transfers are done over SSL and the encryption key to decrypt your data source config is not persisted anywhere on the server. See [here][JackDB Security] for more details about how JackDB handles security.

## Why does it say my token is expired?

The connection tokens expire after a couple minutes (currently 5) and the server rejects connection attempts for expired tokens. If you receive this error then try running the plugin command again and it should work.

## License
The source code for this plugin is released under the MIT license. See the file LICENSE.

Use of this plugin with JackDB's services shall be subject to the [Terms of Service][JackDB Terms].

## Copyright

Copyright &copy; 2013 JackDB, Inc.

[JackDB]: http://www.jackdb.com/
[Contact]: mailto:hello@jackdb.com?subject=JackDB%20Heroku%20Plugin
[JackDB Security]: http://www.jackdb.com/legal/security.html
[JackDB Terms]: http://www.jackdb.com/legal/terms.html
[JackDB Networking]: http://wwww.jackdb.com/docs/index.html#networking
[PostgreSQL]: http://www.postgresql.org/
[MySQL]: http://www.mysql.com/
[MariaDB]: https://mariadb.org/
[Heroku Postgres]: https://postgres.heroku.com/
[Xeround MySQL]: http://xeround.com/
[ClearDB MySQL]: http://www.cleardb.com/