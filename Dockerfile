# Extend from the official Elixir image
FROM bitwalker/alpine-elixir-phoenix:latest

WORKDIR /app

COPY mix.exs .
COPY mix.lock .

RUN mkdir assets

COPY assets/package.json assets

CMD mix deps.get && cd assets && rm -rf ./node_modules && npm install && cd .. && mix phx.server
