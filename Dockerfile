FROM ruby:3.1.3-alpine3.16 AS base

RUN apk add --update yarn build-base bash libcurl git tzdata && rm -rf /var/cache/apk/*
RUN apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/v3.16/main/ nodejs

FROM base AS dependencies

RUN apk add --update build-base

COPY Gemfile* .ruby-version ./
RUN bundle config set without 'development test' && bundle install --jobs=3 --retry=3

COPY package.json yarn.lock ./
RUN yarn install --production --check-files --frozen-lockfile

FROM base

ARG UID=1001

# Uncomment for load testing
# Copy Go and install Vegeta
# COPY --from=golang:1.16-alpine /usr/local/go/ /usr/local/go/
# ENV PATH="/usr/local/go/bin:${PATH}"
# RUN go get -u github.com/tsenart/vegeta

RUN addgroup -g ${UID} -S appgroup && adduser -u ${UID} -S appuser -G appgroup

WORKDIR /app

RUN chown appuser:appgroup /app

ADD --chown=appuser:appgroup https://s3.amazonaws.com/rds-downloads/rds-ca-2019-root.pem ./rds-ca-2019-root.pem
ADD --chown=appuser:appgroup https://s3.amazonaws.com/rds-downloads/rds-ca-2015-root.pem ./rds-ca-2015-root.pem
ADD --chown=appuser:appgroup https://truststore.pki.rds.amazonaws.com/eu-west-2/eu-west-2-bundle.pem ./eu-west-bundle.pem
RUN cat ./rds-ca-2019-root.pem > ./rds-ca-bundle-root.crt
RUN cat ./rds-ca-2015-root.pem >> ./rds-ca-bundle-root.crt
RUN cat ./eu-west-bundle.pem >> ./rds-ca-bundle-root.crt
RUN chown appuser:appgroup ./rds-ca-bundle-root.crt

COPY --chown=appuser:appgroup --from=dependencies /usr/local/bundle/ /usr/local/bundle/
COPY --chown=appuser:appgroup --from=dependencies /node_modules/ node_modules/
COPY --chown=appuser:appgroup . .

ENV APP_PORT 3000
EXPOSE $APP_PORT

USER ${UID}

# Govuk Publishing Components gem requires these env vars to be set, however we
# do not actually need to use them.
ENV GOVUK_APP_DOMAIN ''
ENV GOVUK_WEBSITE_ROOT ''

ARG RAILS_ENV=production

RUN gem install bundler
RUN ./bin/webpack
RUN ASSET_PRECOMPILE=true RAILS_ENV=${RAILS_ENV} SECRET_KEY_BASE=$(bin/rake secret) bundle exec rake assets:precompile --trace

CMD bundle exec rails s -e ${RAILS_ENV} -p ${APP_PORT} --binding=0.0.0.0
