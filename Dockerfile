FROM ruby:3.3

RUN apt-get update && apt-get install -y libsqlite3-dev

WORKDIR /app
COPY Gemfile devise-pwned_password.gemspec ./
COPY lib/devise/pwned_password/version.rb lib/devise/pwned_password/

RUN bundle install --jobs 4 --retry 3

COPY . .

# Re-run bundle install if DEVISE_VERSION is set to a different version
CMD if [ -n "$DEVISE_VERSION" ]; then bundle install --jobs 4 --retry 3; fi && bin/test
