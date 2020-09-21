FROM ruby:2.7.1-slim-buster

RUN gem install bundler
RUN sed -i 's#http://deb.debian.org#https://mirrors.163.com#g' /etc/apt/sources.list && \
  apt update && apt install -y curl gnupg && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt update

RUN apt install -y ca-certificates nodejs cron socat curl git htop tzdata imagemagick nginx libnginx-mod-http-image-filter libnginx-mod-http-geoip  \
  build-essential ruby-dev openssl libpq-dev libxml2-dev libxslt-dev yarn

RUN curl https://get.acme.sh | sh

ENV RAILS_ENV "production"
WORKDIR /home/app/coderlane
RUN mkdir -p /home/app
ADD Gemfile Gemfile.lock package.json yarn.lock /home/app/coderlane/
RUN gem install puma -v '~> 3.11'
RUN bundle config set deployment 'true' && bundle install && yarn

RUN bundle exec rails assets:precompile RAILS_PRECOMPILE=1 RAILS_ENV=production SECRET_KEY_BASE=fake_secure_for_compile