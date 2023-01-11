# AppBuilder (v2) Production Runtime

The server side runtime for our AppBuilder project. This is meant for productions servers without root access, or for servers using container systems other than Docker. Recommend using [ab-cli](https://github.com/digi-serve/ab-cli) to install if possible.

This is for setting up an instance of the AppBuilder docker production stack on a server.

## Installation

You need git and Docker. Then clone this repo.

## Instructions

There is a somewhat complicated system for storing config settings in V2. For 
the production runtime, we try to consolidate all of this into a single `.env`
file. A sample is provided as `example.env`. Modify that to fit your own server
setup, and save it as `.env`.

## Config

The most important setting to change is `MYSQL_PASSWORD`. This will be your
DB root password. Choose something secure.

Important note: When the MariaDB container starts up for the first
time, it will set the database root password to the value you have
specified. After that first time, changing this value will not affect the 
already established password.

Make sure to add your own settings _before_ running the setup steps below.


## Data

### Directories used for persistent storage

- **./mysql/init**

  The SQL files contained here will be used to populate the database for the
  first time.
  
With V2, much of the config and data are actually saved onto Docker volumes, and are not directly binded to directories anymore. The data backup procedure is left as an exercise for the reader.

# Usage

## Preparation

Follow the **Instructions** section on configuring your DB credentials
and other settings.

In order to issue Docker commands, your user account must either have root
access, or be part of the _docker_ group.

The following steps need to be done with the same docker stack name you plan to
run AppBuilder with (referred to here as `mystack`). This should match the 
`STACKNAME` setting in your `.env` file.

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

The default account credentials are:
- email: `admin@example.com`
- password: `admin`

## Stop AppBuilder

```sh
$ docker stack rm mystack
```

## View console

```sh
$ docker service logs -f mystack_api_sails
```

Note you can use the same command to view logs from each service.
