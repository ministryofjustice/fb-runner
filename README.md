# README

To run the project locally, execute the following steps:
- Install Ruby dependencies `bundle install`
- Install all dependencies `yarn install`
- Bundle JavaScript assets `./bin/webpack`
- Start the Rails server `bundle exec rails s`
- The application should run on `localhost:3000`

## Datastore integration

The runner can be run without a datastore (through the session) but
in case you want to connect with the datastore you can do via docker:

```
   make setup
```

Then `open localhost:9000` to see the runner in the browser.
