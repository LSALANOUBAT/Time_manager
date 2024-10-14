FROM elixir:latest

WORKDIR /time_manager

COPY ./time_manager/mix.exs mix.exs
COPY ./time_manager/mix.lock mix.lock

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs
RUN mix local.hex --force && mix local.rebar --force

COPY ./time_manager .
RUN mix deps.get
RUN mix deps.compile && mix compile


EXPOSE 4000
CMD ["mix", "phx.server"]
