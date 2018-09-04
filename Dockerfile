FROM ruby:2.5

ENV RAILS_ENV=production
EXPOSE 3000

RUN mkdir -p /app
ADD . /app
WORKDIR /app
RUN bundle install

CMD ["rails", "server"]