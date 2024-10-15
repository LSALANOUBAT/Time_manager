FROM elixir:latest

WORKDIR /time_manager

# Copier les fichiers de configuration Mix pour gérer les dépendances
COPY mix.exs mix.lock ./

RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get

# Copier le reste de l'application
COPY . .

RUN mix deps.compile && mix compile

EXPOSE 4000
CMD ["mix", "phx.server"]
