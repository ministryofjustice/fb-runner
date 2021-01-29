FROM ruby:2.7.2-alpine3.12

ARG UID=1001

RUN apk add --update nodejs yarn build-base bash libcurl git tzdata

RUN addgroup -g ${UID} -S appgroup && \
  adduser -u ${UID} -S appuser -G appgroup

WORKDIR /app

RUN chown appuser:appgroup /app

ADD --chown=appuser:appgroup https://s3.amazonaws.com/rds-downloads/rds-ca-2019-root.pem ./rds-ca-2019-root.pem
ADD --chown=appuser:appgroup https://s3.amazonaws.com/rds-downloads/rds-ca-2015-root.pem ./rds-ca-2015-root.pem
RUN cat ./rds-ca-2019-root.pem > ./rds-ca-bundle-root.crt
RUN cat ./rds-ca-2015-root.pem >> ./rds-ca-bundle-root.crt
RUN chown appuser:appgroup ./rds-ca-bundle-root.crt

COPY --chown=appuser:appgroup Gemfile* .ruby-version ./

RUN gem install bundler

RUN bundle config set no-cache 'true'
ARG BUNDLE_ARGS='--jobs 2 --retry 3 --without test development'
RUN bundle install ${BUNDLE_ARGS}

COPY --chown=appuser:appgroup . .

ENV APP_PORT 3000
EXPOSE $APP_PORT

USER ${UID}

ARG RAILS_ENV=production
RUN yarn install --production --check-files
RUN ASSET_PRECOMPILE=true RAILS_ENV=${RAILS_ENV} SECRET_KEY_BASE=$(bin/rake secret) bundle exec rake assets:precompile --trace
CMD bundle exec rails s -e ${RAILS_ENV} -p ${APP_PORT} --binding=0.0.0.0
