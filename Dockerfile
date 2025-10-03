FROM ruby:3.1

# Install system dependencies and dockerize
RUN apt-get update && apt-get install -y \
    default-libmysqlclient-dev \
    nodejs \
    wget

# Install dockerize
RUN wget https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-linux-amd64-v0.6.1.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-v0.6.1.tar.gz \
    && rm dockerize-linux-amd64-v0.6.1.tar.gz

WORKDIR /app

# Copy Gemfile first for better Docker layer caching
COPY Gemfile* ./
RUN gem install rails bundler && \
    bundle config --global retry 3 && \
    bundle config --global timeout 30 && \
    bundle install --jobs 4

# Copy the rest of the application
COPY . .
