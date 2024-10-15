FROM cimg/elixir:latest

ADD . /time_manager

RUN mix local.hex --force \
    && mix archive.install --force hex phx_new \
    && apt-get update \
    && curl -sL https://deb.nodesource.com/setup_lts.x | bash \
    && apt-get install -y apt-utils \
    && apt-get install -y nodejs \
    && apt-get install -y build-essential \
    && apt-get install -y inotify-tools \
    && mix local.rebar --force

WORKDIR /time_manager

# Copier les fichiers de configuration Mix pour gérer les dépendances
COPY ./time_manager/mix.exs mix.exs
COPY ./time_manager/mix.lock mix.lock


# Copier le reste de l'application
COPY ./time_manager .

RUN mix deps.compile && mix compile

EXPOSE 4000
CMD ["mix", "phx.server"]

