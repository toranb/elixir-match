FROM elixir:1.8.0

RUN mix local.hex --force
RUN mix local.rebar --force

COPY . /example
WORKDIR /example

RUN apt-get update
RUN apt-get install make gcc libc-dev

RUN mix deps.get && mix deps.compile && mix compile

RUN chmod +x entrypoint.sh

EXPOSE 4000
