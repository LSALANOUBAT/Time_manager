FROM elixir:latest

WORKDIR /time_manager

COPY ./time_manager/mix.exs mix.exs
COPY ./time_manager/mix.lock mix.lock

RUN mix local.hex --force && mix local.rebar --force

COPY ./time_manager .
RUN mix deps.get
RUN mix deps.compile && mix compile


EXPOSE 4000
CMD ["mix", "phx.server"]
