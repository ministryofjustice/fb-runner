# README

## Setup
Ensure you are running Node version 16.19.1 LTS. Easiest is to install [NVM](https://github.com/nvm-sh/nvm#installing-and-updating) and then:
`nvm install 16.19.1`
`nvm use 16.19.1`

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

If you need to have any autocomplete fixtures for local development you can use
set AUTOCOMPELTE_FIXTURE to be the name of your fixture file containing the JSON
representation of your items. By default this will set the contents of a fixture
file called `countries.json` which can be found in the MetadataPresenter.

```
  AUTOCOMPLETE_FIXTURE=countries bundle exec rails s
```

- The application should run on `localhost:3000`

## Datastore integration

The runner can be run without a datastore (through the session) but
in case you want to connect with the datastore you can do via docker:

```
   make setup
```

Then `open localhost:9000` to see the runner in the browser.
