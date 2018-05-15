FROM ruby:2.5.0

ENV APP_HOME=/home/app

RUN groupadd -r app --gid=1000 \
 && useradd -r -m -g app -d $APP_HOME --uid=1000 app \
 # Install system dependencies.
 && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update \
 && apt-get install -y \
      default-libmysqlclient-dev \
      nodejs \
      yarn

WORKDIR $APP_HOME

# Install dependencies defined in Gemfile.
COPY --chown=app Gemfile Gemfile.lock $APP_HOME/

RUN mkdir -p /opt/vendor/bundle \
 && chown -R app:app /opt/vendor \
 && su app -s /bin/bash -c "bundle install --path /opt/vendor/bundle"

# Copy the main application.
COPY --chown=app . $APP_HOME

USER app

RUN ./bin/init_config \
 && bundle exec rake tmp:create yarn:install assets:precompile

EXPOSE 8080

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD ["bundle", "exec", "puma", "--config", "config/puma.rb"]
