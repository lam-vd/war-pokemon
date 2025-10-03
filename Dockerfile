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
COPY . .
RUN gem install rails bundler
