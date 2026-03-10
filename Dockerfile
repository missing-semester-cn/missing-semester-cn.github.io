FROM ruby:3.4-alpine3.21

RUN apk add --no-cache ruby-dev alpine-sdk

RUN mkdir /app
COPY Gemfile Gemfile.lock \
    /app/
WORKDIR /app
RUN bundle install

CMD ["bundle", "exec", "jekyll", "serve", "-w", "--host", "0.0.0.0"]
