FROM elixir:1.14.3-alpine

RUN apk update && \
  apk add postgresql-client inotify-tools
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
CMD [ "/app/entrypoint.sh" ]