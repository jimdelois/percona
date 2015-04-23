## Percona Server Dockerfile


This repository contains **Dockerfile** of [Percona Server](http://www.percona.com/software/percona-server) for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/bryanlatten/percona/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

**This repository is intended to be a drop-in replacement for the original "dockerfile/percona" repository which used to exist at https://registry.hub.docker.com/u/dockerfile/percona/**


### Base Docker Image

* [dockerfile/ubuntu](http://dockerfile.github.io/#/ubuntu)


### Installation

1. Install [Docker](https://www.docker.com/).

2. Download [automated build](https://registry.hub.docker.com/u/bryanlatten/percona/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull bryanlatten/percona`

   (alternatively, you can build an image from Dockerfile: `docker build -t="bryanlatten/percona" github.com/bryanlatten/percona`)


### Usage

#### Run `mysqld-safe`

    docker run -d --name mysql -p 3306:3306 bryanlatten/percona

#### Run `mysqld-safe` With a Schema Import

If you have a set of SQL files you would like to import into the container (e.g., a DDL schema or fixturization files), you can mount in a parent directory of those files, specify an environment variable describing the mounted location, and executing the `run.sh` command directly.  The container allows for multiple DBs to be imported by following a convention and `run.sh` input syntax.

Given the following structure of SQL files, separated by individual database:

```
/local/path/to/project/ddl/
|- database_one/
|   |- table_one.sql
|   |- table_two.sql
|- database_two/
|   |- table_one.sql
|- database_three/
    |- table_one.sql
    |- table_two.sql
```

You could mount `/local/path/to/project/ddl` into the container as `/ddl`, then specify that very location using an environment config, and tell the run command to import only `database_one` and `database_three` as follows:

    docker run -d --name mysql -p 3306:3306 -e CFG_DB_SCHEMA_DIR="/ddl" -v /local/path/to/project/ddl:/ddl bryanlatten/percona /bin/bash /run.sh database_one:database_two

When using `docker-compose`, this could more conveniently be expressed in your project as:

```
db:
  image: bryanlatten/percona
  volumes:
  - ./ddl:/ddl
  command: /run.sh database_one:database_two
  environment:
    CFG_DB_SCHEMA_DIR: /ddl
  ports:
  - '3306:3306'
```

Additionally, supplying environment variables `CFG_DB_USER` and `CFG_DB_PASSWORD` will create a user with the supplied password and default access to all imported schemas.


#### Run `mysql`

    docker run -it --rm --link mysql:mysql bryanlatten/percona bash -c 'mysql -h $MYSQL_PORT_3306_TCP_ADDR'

