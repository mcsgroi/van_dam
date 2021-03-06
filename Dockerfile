FROM ruby:3.0-alpine AS build

RUN apk add --no-cache tzdata alpine-sdk postgresql-dev nodejs yarn python2

ENV PORT 3214
ENV RACK_ENV production
ENV NODE_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV VAN_DAM_GIT_REF $CI_REF_NAME
ENV VAN_DAM_GIT_SHA $CI_SHA_SHORT

WORKDIR /usr/src/app

COPY package.json .
COPY yarn.lock .
RUN yarn install --prod

RUN gem install bundler -v 2.2.4
RUN bundle config set --local deployment 'true'
RUN bundle config set --local without 'development test'
COPY Gemfile* ./
RUN bundle install

COPY . .
RUN \
  SECRET_KEY_BASE="placeholder" \
  bundle exec rake assets:precompile

EXPOSE 3214
ENTRYPOINT ["bin/docker-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
