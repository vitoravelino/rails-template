FROM ruby:3.0.1-slim-buster

RUN apt-get update -qq && apt-get install -y build-essential git
RUN mkdir /app
WORKDIR /app
COPY Gemfile* /app/
RUN bundle install

EXPOSE 3000
