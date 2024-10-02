# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Set environment variables
ENV APP_HOME /app
WORKDIR $APP_HOME

