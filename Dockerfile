FROM elixir:1.15.0-alpine

RUN apk update && \
  apk add postgresql-client inotify-tools && \
  apk add --update nodejs npm
# Create app directory and copy the Elixir projects into it.
RUN mkdir /app
COPY . /app
WORKDIR /app

EXPOSE 8080
# Install Hex package manager.
# By using `--force`, we don’t need to type “Y” to confirm the installation.
RUN mix local.hex --force

# Compile the project.
RUN mix do compile
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT [ "/app/entrypoint.sh" ]