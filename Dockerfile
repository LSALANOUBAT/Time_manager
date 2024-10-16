# Start with the latest Elixir image
FROM elixir:latest

# Set the working directory to /time_manager
WORKDIR /time_manager

# Copy only the Mix configuration files first for dependency caching
COPY ./time_manager/mix.exs ./mix.exs
COPY ./time_manager/mix.lock ./mix.lock

# Install Hex, Phoenix, and dependencies
RUN mix local.hex --force \
    && mix archive.install --force hex phx_new \
    && apt-get update \
    && curl -sL https://deb.nodesource.com/setup_lts.x | bash \
    && apt-get install -y apt-utils nodejs build-essential inotify-tools \
    && mix local.rebar --force \
    && mix deps.get \
    && mix deps.compile

# Copy the rest of the application files
COPY ./time_manager .

# Compile the application
RUN mix compile

# Expose the Phoenix port
EXPOSE 4000

# Command to start the Phoenix server
CMD ["mix", "phx.server"]
