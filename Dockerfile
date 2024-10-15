FROM elixir:latest

# Définir le répertoire de travail dans le conteneur
WORKDIR /time_manager

# Copier les fichiers mix pour gérer les dépendances
COPY ./mix.exs mix.exs
COPY ./mix.lock mix.lock

# Installer les dépendances Elixir
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get

# Copier le reste de l'application
COPY . .

# Compiler les dépendances et l'application
RUN mix deps.compile && mix compile

# Exposer le port pour Phoenix
EXPOSE 4000

# Lancer le serveur Phoenix
CMD ["mix", "phx.server"]
