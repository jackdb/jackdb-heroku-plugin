# JackDB Heroku Plugin

Extends `heroku` command-line to query and visualize Heroku data sources on [JackDB][].

<a href="http://www.jackdb.com/"><img width="940" height="393" src="http://static.jackdb.com/assets/img/hero.png" alt="JackDB - Screenshot"></a>

## Installation

    $ heroku plugins:install https://github.com/jackdb/jackdb-heroku-plugin.git

## Usage

    $ heroku help jackdb
    Usage: heroku jackdb

	 Open a database in JackDB

	 This will search through your app config for the valid database url and try to connect to it.
	 If you have more than one database then use one of the "jackdb:" commands to connect to a specific one.

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

The JackDB Heroku plugin currently supports [PostgreSQL][], [MySQL][], and [MariaDB][] databases.

JackDB supports a number of other data source types. For more details, [see here][JackDB].

## Can I use this for other types of databases?

We're working on adding support for additional data sources. [Let us know][Contact] what data sources you'd like us to support next.

## Networking & Firewall

The plugin has been tested with [Heroku Postgres][], [Xeround MySQL][], and [ClearDB MySQL][] and works without any additional setup with all three.

If your database is behind a firewall, you will need to open up the appropriate ports to allow JackDB to access it. For details, [see here][JackDB Networking].

## Can I use this with a database running on my local machine or network?

Not yet, but we're working on it. JackDB connects directly to your database so it's not currently possible to reach databases that are behind a firewall.

## How does it work?

The plugin works in three steps.

First the plugin identifies the database to connect to. By default, the plugin attempts to get configuration details for the PostgreSQL database in the Heroku configuration property `DATABASE_URL`. The plugin's other commands change where to look for a database configuration and what type of configuration to look for.

Then, if the plugin finds a valid database configuration, it sends a `POST` request to JackDB with the config information for your database. The JackDB server:
 
  1. Generates a unique random id for the request.
  1. Generates a random encryption key.
  1. Encrypts the data source config information with the key using AES-256-CBC.
  1. Saves the encrypted database configuration details, keyed by the id.
  1. Returns back a signed token containing the encryption key and id.

The encryption key used to encrypt your database configuration details is not saved by JackDB, and is only sent in response to the plugin's `POST` request.

Finally, the plugin then generates a URL to log in directly to JackDB using the token from the previous step and opens using your default web browser. If you're already logged into JackDB, then we'll immediately connect you to your data source. If not, then you'll be sent to the login page.

If your browser does not open automatically, the URL is also printed.

No attempt to connect to your data source is made until after you log in and open the URL in your browser.

## Do I need to install JackDB?

No. JackDB works entirely in your web browser.

## Is it secure?

All data transfer is done using SSL and the encryption key to decrypt your data source configuration is not persisted anywhere on the JackDB server. See [here][JackDB Security] for more on how JackDB handles security.

## Why does it say my token is expired?

The connection tokens expire after a couple of minutes (currently five) and the server rejects connection attempts for expired tokens. If you receive this error then try running the plugin command again and it should work.

## License
The source code for this plugin is released under the MIT license. See the file LICENSE.

Use of this plugin with JackDB's services shall be subject to the [Terms of Service][JackDB Terms].

## Copyright

Copyright &copy; 2013 JackDB, Inc.

[JackDB]: http://www.jackdb.com/
[Contact]: mailto:hello@jackdb.com?subject=JackDB%20Heroku%20Plugin
[JackDB Security]: http://www.jackdb.com/legal/security.html
[JackDB Terms]: http://www.jackdb.com/legal/terms.html
[JackDB Networking]: http://www.jackdb.com/docs/index.html#networking
[PostgreSQL]: http://www.postgresql.org/
[MySQL]: http://www.mysql.com/
[MariaDB]: https://mariadb.org/
[Heroku Postgres]: https://postgres.heroku.com/
[Xeround MySQL]: http://xeround.com/
[ClearDB MySQL]: http://www.cleardb.com/
