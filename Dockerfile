FROM ruby:3.2.2-alpine

WORKDIR /opt/spoker-master

ENV BUILD_DEPS=build-base
ENV RUNTIME_DEPS='postgresql-dev tzdata'

COPY Gemfile Gemfile.lock ./
RUN    apk add --no-cache $BUILD_DEPS $RUNTIME_DEPS \
    && echo -e 'gem: --no-document --no-rdoc --no-ri' >> /etc/gemrc \
    && bundle config set clean true \
    && bundle config set deployment true \
    && bundle config set without 'development test' \
    && bundle install --jobs 20 --retry 5 \
    && apk del $BUILD_DEPS

COPY . ./

ENV USER=spoker-master
RUN    adduser -u 1002 -D $USER \
    && chown -R $USER:$USER `pwd`
USER $USER

ARG RAILS_MASTER_KEY
ARG RAILS_ENV

ENV RAILS_ENV=${RAILS_ENV:-production}
ENV RAILS_LOG_TO_STDOUT=true

RUN bundle exec rails assets:precompile

CMD ["/usr/local/bin/bundle", "exec", "foreman", "start", "web"]
