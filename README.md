# AppBuilder (v2) Production Runtime

The server side runtime for our AppBuilder project. This is meant for productions servers without root access. Recommend using [ab-cli](https://github.com/digi-serve/ab-cli) to install if possible.

This is for setting up an instance of the AppBuilder docker production stack on a server.

## Installation

You need git and Docker. Then clone this repo.

## Instructions

### docker-compose-override.yml

You will want to edit this to expose ports from the Docker containers
to be accessible from the outside via your chosen external port numbers.

#### **Required**

The main user facing component using regular unencrypted http. Typically, there will
be an nginx or apache layer on the host server that does the SSL/TLS on top of
this.

```yaml
web:
  ports:
    - "[external port]:1337"
```

#### **Optional**

MariaDB. Expose it for debugging data or doing mysqldump backups.

```yaml
db:
  ports:
    - "[external port]:3306"
```

## Config

There are two config files that the AppBuilder stack will rely on.
Make sure to edit them with your own settings _before_ running the setup steps below.

1. **./config/local.js**

   This the main AppBuilder config, determining which service are enabled and options for them.

2. **./mysql/password**

   This is a plaintext file. Its value will be used to fill
   the connections section from `./config/local.js`. **This
   will be your root DB password.** Choose something secure.

   Important note: When the MariaDB container starts up for the first
   time, it will set the database root password to the value you have
   specified in this password file. After that first time, changing
   this value will not affect the already established password.

   If your database is already set up, this password file must still be
   entered correctly as it will automatically be replicated into the
   `./config/local.js` file on every start up.

## Data

### Directories used for persistent storage

- **./mysql/data**

  This is where the MariaDB server will save its data. Do not manually edit
  files from here unless you really know what you are doing. If you want to
  start from scratch again and discard all existing data, you can delete the
  contents of this directory.

- **./mysql/init**

  The SQL files contained here will be used to populate the database for the
  first time.

- **./redis/data**

  This is where the redis server will save its data.

- **./data**

  This is where AppBuilder will store any files uploaded by users.

# Usage

## Preparation

Follow the **Instructions** section on configuring your DB credentials
and other settings.

In order to issue Docker commands, your user account must either have root
access, or be part of the _docker_ group.

The following steps need to be done with the same docker stack name you plan to run AppBuilder with (referred to here as `mystack`).

1. Turn on Docker Swarm if needed:

   ```bash
   $ docker swarm init
   ```

1. Create the nginx_etc volume

   ```bash
   $ docker run -v mystack_nginx_etc:/etc nginx ls
   ```

1. Run config-compose.yml

   ```bash
   $ docker stack deploy -c config-compose.yml mystack
   ```

   - Open the logs for `mystack_config`
     ```bash
     $ docker service logs -f mystack_config
     ```
   - Bring down the stack when you see `... init complete (config)`
     ```bash
     $ docker stack rm mystack
     ```

1. Run dbinit-compose.yml

   ```bash
   $ docker stack deploy -c dbinit-compose.yml mystack
   ```

   - Open the logs for `mystack_db`
     ```bash
     $ docker service logs -f mystack_db
     ```
   - Bring down the stack when you see `mysqld: ready for connections`
     ```bash
     $ docker stack rm mystack
     ```

## Start AppBuilder

```sh
$ docker stack deploy -c docker-compose.yml -c docker-compose.override.yml mystack
```

## Stop AppBuilder

```sh
$ docker stack rm mydtack
```

## View console

```sh
$ docker service logs -f mystack_api_sails
```

Note you can use the same command to view logs from each service.
