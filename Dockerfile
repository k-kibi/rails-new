ARG ruby_version
FROM ruby:${ruby_version}-buster as base

WORKDIR /k-kibi/rails-new

ENV BUNDLE_PATH=/vendor/bundle \
  RUBYGEMS_VERSION=3.2.3

RUN apt-get update -q && apt-get upgrade -y && \
  gem update --system $RUBYGEMS_VERSION && gem install bundler

FROM base as dev

COPY docker /docker

ENV ENTRYKIT_VERSION 0.4.0
RUN cd / \
  &&  wget https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && tar -xvzf entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && rm entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && mv entrykit /bin/entrykit \
  && chmod +x /bin/entrykit \
  && entrykit --symlink

ENTRYPOINT ["prehook", "/docker/prehook", "--"]

COPY Gemfile Gemfile.lock ./

RUN bundle lock --add-platform x86_64-linux && bundle install

COPY . .
