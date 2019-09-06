FROM ruby:2.6.4

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=1
EXPOSE 3000

RUN mkdir -p /app
ADD . /app
WORKDIR /app
RUN gem install bundler:2.0.2
RUN bundle install

CMD rm -f tmp/pids/server.pid && rails server -p 3000 -b 0.0.0.0