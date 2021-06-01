# README

## Setup
Ensure you are running on Node version 14.17.0:
`nvm use 14.17.0`

To run the project locally, execute the following steps:
- Install Ruby dependencies: `bundle install`
- Compile all assets and run webpack: `make assets`

## Start the Rails server

The runner requires a service metadata to render the form.

Or you can bypass any metadata and start the server:

```
  SERVICE_METADATA="{ #... json service metadata }" bundle exec rails s
```

Alternatively you can pass a service fixture that will load any fixture from
the metadata presenter fixture dir:
```
  # this will load the version.json from the metadata presenter fixture dir
  SERVICE_FIXTURE=version bundle exec rails s
```

- The application should run on `localhost:3000`

## Datastore integration

The runner can be run without a datastore (through the session) but
in case you want to connect with the datastore you can do via docker:

```
   make setup
```

Then `open localhost:9000` to see the runner in the browser.
