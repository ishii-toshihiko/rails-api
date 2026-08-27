# Dockerfile
ARG RUBY_VERSION=3.3.0
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

RUN apt-get update -qq && \
   apt-get install -y --no-install-recommends \
     apt-utils curl libjemalloc2 libvips postgresql-client \
     git build-essential libpq-dev sudo && \
   rm -rf /var/lib/apt/lists/*

ENV APP_HOME=/app
RUN mkdir -p ${APP_HOME}
WORKDIR ${APP_HOME}
COPY . ${APP_HOME}

RUN bundle install

ADD . /myapp
RUN rm -f /myapp/tmp/pids/server.pid

ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

FROM base AS build

COPY Gemfile Gemfile.lock ./

COPY . .

RUN mkdir -p db log storage tmp

FROM base

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app
RUN chmod +x /app/bin/docker-entrypoint

ENTRYPOINT ["/app/bin/docker-entrypoint"]

ENV PORT=8080
EXPOSE 8080

# Cloud Run は PORT で待受が必要。DB は VPC / POSTGRES_HOST 経由を想定
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "8080"]
