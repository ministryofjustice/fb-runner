# README

To run the project locally, execute the following steps:
- Install Ruby dependencies `bundle install`
- Install all dependencies `yarn install`
- Bundle JavaScript assets `./bin/webpack`

## Start the Rails server

The runner requires a service metadata to render the form.

In production the service metadata env var is required but in development
will use the version.json from the metadata presenter gem.

If you want to use the default version.json just start the Rails server:

`bundle exec rails s`

If you want to pass another fixture from the gem you can run:

```
  # this will load the service.json from the metadata presenter fixture dir
  SERVICE_FIXTURE=service bundle exec rails s
```

Or you can bypass any metadata and start the server:

```
  SERVICE_METADATA="{ #... json service metadata }" bundle exec rails s
```

- The application should run on `localhost:3000`

## Datastore integration

The runner can be run without a datastore (through the session) but
in case you want to connect with the datastore you can do via docker:

```
   make setup
```

Then `open localhost:9000` to see the runner in the browser.
