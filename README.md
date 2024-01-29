[![GitHub release](https://img.shields.io/github/downloads-pre/digi-serve/ab_runtime/latest/total?label=Version)](https://github.com/digi-serve/ab_runtime/releases)


The server side runtime for our AppBuilder project.

## Installation
Use [ab-cli](https://github.com/digi-serve/ab-cli) tool.

## Starting
Run `./UP.sh` to bring up the Docker Stack. Options:
- `-d` : **dev** run develop mode (uses docker-compose.dev.yml)
- `-t` : **test** run in test mode (allows test reset route)
- `-q` : **quiet** run without starting logs 

The default account credentials are:
- email: `admin@example.com`
- password: `admin`

## Updating
Run`git pull` to update the version file (`version.json`).\
Then run `node dockerImageUpdate` to update the running services.

## Data

### Directories used for persistent storage

- **./mysql/init**

  The SQL files contained here will be used to populate the database for the
  first time.
  
Much of the config and data are actually saved onto Docker volumes, and are not directly binded to directories anymore. The data backup procedure is left as an exercise for the reader.


## Manual Installation

The ab-cli will help set the config and write `.env`, `docker-compose.yml`, and
`docker-compose.override.yml`. Examples can be found in `/examples/`, for a
manual install copy these files to the root directory and adjust them as needed.

### Config

The most important setting to change is `MYSQL_PASSWORD`. This will be your
DB root password. Choose something secure.

Important note: When the MariaDB container starts up for the first
time, it will set the database root password to the value you have
specified. After that first time, changing this value will not affect the 
already established password.

Make sure to add your own settings _before_ running the setup steps below.

### Preparation

Follow the **Config** section on configuring your DB credentials
and other settings.

The following steps need to be done with the same docker stack name you plan to
run AppBuilder with (referred to here as `mystack`). This should match the 
`STACKNAME` setting in your `.env` file.

1. Turn on Docker Swarm if needed
   ```bash
   $ docker swarm init
   ```
1. Copy dbinit-compose.yml from /examples to the project root.
   ```bash
   $ cp ./examples/dbinit-compose.yml ./dbinit-compose.yml
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
1. Remove dbinit-compose.yml
   ```bash
   $ rm ./dbinit-compose.yml
   ```
1. Run db migrations
   ```bash
   $ ./migrate.sh
   ```

## Stop AppBuilder

```sh
$ ./Down.sh
```

## View console

```sh
$ node logs
// or
$ ./logs.sh [option]
```

Note you can use the same command to view logs from each service.
