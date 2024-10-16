FROM elixir:latest

# Définir le répertoire de travail
WORKDIR /time_manager

# Copier le code source du projet
ADD . /time_manager

# Installer les outils et dépendances nécessaires
RUN mix local.hex --force \
    && mix archive.install --force hex phx_new \
    && apt-get update \
    && curl -sL https://deb.nodesource.com/setup_lts.x | bash \
    && apt-get install -y apt-utils \
    && apt-get install -y nodejs \
    && apt-get install -y build-essential \
    && apt-get install -y inotify-tools \
    && mix local.rebar --force

# Install Hex and Phoenix globally
RUN mix local.hex --force && \
    mix archive.install hex phx_new --force

# Copier les fichiers de configuration Mix pour gérer les dépendances
COPY ./time_manager/mix.exs mix.exs
COPY ./time_manager/mix.lock mix.lock

# Copier le reste de l'application
COPY ./time_manager .

# Compiler les dépendances
RUN mix deps.get
RUN mix deps.compile && mix compile

# Exposer le port pour l'application Phoenix
EXPOSE 4000

# Commande pour démarrer le serveur Phoenix
CMD ["mix", "phx.server"]
