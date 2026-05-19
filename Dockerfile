# --- Stage 1: Base ---
FROM ruby:3.3.11-alpine AS base

RUN apk add --update build-base bash libcurl git tzdata libffi-dev yaml-dev && rm -rf /var/cache/apk/*

# Install Node 16 and Yarn by copying from official image
COPY --from=node:16.20.1-alpine /usr/local/bin/node /usr/local/bin/
COPY --from=node:16.20.1-alpine /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node:16.20.1-alpine /opt/yarn-v1.22.19 /opt/yarn
RUN ln -s /usr/local/bin/node /usr/local/bin/nodejs && \
    ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn && \
    ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg

# --- Stage 2: Builder (Install Dependencies) ---
FROM base AS builder

# Set a workdir so we know exactly where files are
WORKDIR /app

COPY Gemfile* .ruby-version package.json yarn.lock ./
RUN bundle config set force_ruby_platform true
RUN bundle install --no-cache --jobs=3 --retry=3 --without test development

# This creates /app/node_modules
RUN yarn install --production --check-files --frozen-lockfile

# --- Stage 3: Runner (Final Image) ---
FROM base AS runner

ARG UID=1001
RUN addgroup -g ${UID} -S appgroup && adduser -u ${UID} -S appuser -G appgroup

WORKDIR /app
RUN chown appuser:appgroup /app

# Setup RDS Certs
ADD --chown=appuser:appgroup https://s3.amazonaws.com/rds-downloads/rds-ca-2019-root.pem ./
ADD --chown=appuser:appgroup https://s3.amazonaws.com/rds-downloads/rds-ca-2015-root.pem ./
RUN cat rds-ca-2019-root.pem rds-ca-2015-root.pem > rds-ca-bundle-root.crt && \
    chown appuser:appgroup rds-ca-bundle-root.crt

# FIX: Copy from the 'builder' stage using absolute paths
COPY --chown=appuser:appgroup --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --chown=appuser:appgroup --from=builder /app/node_modules/ ./node_modules/

# Copy the rest of the app
COPY --chown=appuser:appgroup . .

ENV APP_PORT=3000 \
    GOVUK_APP_DOMAIN='' \
    GOVUK_WEBSITE_ROOT='' \
    RAILS_ENV=production

USER ${UID}

RUN ./bin/webpack
RUN ASSET_PRECOMPILE=true SECRET_KEY_BASE=$(bin/rails secret) bundle exec rake assets:precompile --trace

CMD ["bundle", "exec", "rails", "s", "-e", "production", "-p", "3000", "--binding=0.0.0.0"]