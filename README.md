

[![Build Status](https://travis-ci.org/rchampourlier/letto.svg?branch=master)](https://travis-ci.org/rchampourlier/letto)
[![Code Climate](https://codeclimate.com/github/rchampourlier/letto/badges/gpa.svg)](https://codeclimate.com/github/rchampourlier/letto)
[![Test Coverage](https://codeclimate.com/github/rchampourlier/letto/badges/coverage.svg)](https://codeclimate.com/github/rchampourlier/letto/coverage)
[![Issue Count](https://codeclimate.com/github/rchampourlier/letto/badges/issue_count.svg)](https://codeclimate.com/github/rchampourlier/letto)

## Purpose

LET's auTOmate!

## How to use

### Ngrok

In development, to perform OAuth handshake with Trello, you will need
to publish your local server. You may use ngrok for this.

```
ngrok http 9292
```

### Walkthrough

```
# Start dependencies (PostgreSQL) through Docker
docker-compose up -d

# Ruby environment setup
gem install bundler
bundle install

# Run migrations
bin/db/migrate

# Reset the database
bin/db/reset

# Open a console
bin/console

# Start a development server
guard

# Or directly with rackup
rackup
```

### Deploy to Heroku

```sh
# Staging
bin/set_env_staging
bin/deploy staging

# Production
bin/set_env_production
bin/deploy production
```

### Run a console on Heroku

```
heroku run bin/console -a <APP-NAME>
```

### Dump the production database

_NB: this assumes you have deployed to Heroku_

```
bin/dump_production_to_local
bin/dump_production_to_staging
```
