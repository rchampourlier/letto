

[![Build Status](https://travis-ci.org/rchampourlier/letto.svg?branch=master)](https://travis-ci.org/rchampourlier/letto)
[![Code Climate](https://codeclimate.com/repos/5659c9ee09af1e152f00d540/badges/d4a9abf44cad651805e5/gpa.svg)](https://codeclimate.com/repos/5659c9ee09af1e152f00d540/feed)
[![Coverage Status](https://coveralls.io/repos/github/rchampourlier/letto/badge.svg?branch=master)](https://coveralls.io/github/rchampourlier/letto?branch=master)

## Purpose

LET's auTOmate!

## How to use

### Open a console locally

```
bin/console
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
