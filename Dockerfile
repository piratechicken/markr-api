FROM ruby:2.6.5
ENV BUNDLER_VERSION="2.1.2"

RUN apt-get update -qq && apt-get install -y postgresql-client
RUN mkdir /markr-api
WORKDIR /markr-api
COPY Gemfile /markr-api/Gemfile
COPY Gemfile.lock /markr-api/Gemfile.lock

RUN gem install -q --no-document bundler --version $BUNDLER_VERSION --force
RUN bundle install

COPY . /markr-api

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
