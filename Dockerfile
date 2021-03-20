FROM ruby:3.0.0
# throw errors if Gemfile has been modified since Gemfile.lock
RUN gem install bundler:2.2.15
RUN bundle config --global frozen 1
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp