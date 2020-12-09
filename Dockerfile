FROM ruby:2.7.2-alpine3.12

RUN apk add --update nodejs yarn build-base bash libcurl git tzdata

RUN addgroup -g 1001 -S appgroup && \
  adduser -u 1001 -S appuser -G appgroup

WORKDIR /app

COPY Gemfile* .ruby-version ./

ARG BUNDLE_FLAGS
RUN gem install bundler
RUN bundle install --jobs 2 --retry 3 --no-cache ${BUNDLE_FLAGS}

COPY . .

ADD https://s3.amazonaws.com/rds-downloads/rds-ca-2019-root.pem ./rds-ca-2019-root.pem
ADD https://s3.amazonaws.com/rds-downloads/rds-ca-2015-root.pem ./rds-ca-2015-root.pem
RUN cat ./rds-ca-2019-root.pem > ./rds-ca-bundle-root.crt
RUN cat ./rds-ca-2015-root.pem >> ./rds-ca-bundle-root.crt

RUN chown -R 1001:appgroup /app
USER 1001

ENV APP_PORT 3000
EXPOSE $APP_PORT

ARG RAILS_ENV=production
RUN yarn install --check-files
RUN RAILS_ENV=${RAILS_ENV} SECRET_KEY_BASE=$(bin/rake secret) bundle exec rake assets:precompile --trace
CMD bundle exec rails s -e ${RAILS_ENV} -p ${APP_PORT} --binding=0.0.0.0
