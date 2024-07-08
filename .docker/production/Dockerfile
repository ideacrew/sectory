# File: docker_phx/Dockerfile
FROM elixir:1.17.1-alpine as build

# install build dependencies
RUN apk add --update git build-base nodejs npm yarn python3

RUN mkdir /app
WORKDIR /app

# install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# build assets
COPY assets assets
RUN cd assets && npm install 
# && npm run deploy
RUN mix phx.digest

# build project
COPY priv priv

COPY lib lib

RUN mix sbom --output=sectory-hex.sbom

COPY assets assets

# build release
# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

FROM alpine:3.19 as alpine-inventory


# prepare sbom image
FROM --platform=amd64 ruby:3.3-bookworm AS sbomber

# RUN apk add --update npm git build-base gcompat curl
RUN apt-get update && apt-get -y install nodejs npm

RUN mkdir /sbom_generation
RUN mkdir /sbom_generation/apk
RUN mkdir /sbom_generation/npm

WORKDIR /sbom_generation

ARG COMMIT_SHA

ENV COMMIT_SHA=$COMMIT_SHA

RUN npm install --global @cyclonedx/cyclonedx-npm

COPY sectory-alpine-inventory.sbom ./
COPY --from=build /app/sectory-hex.sbom ./
COPY --from=build /app/assets/package-lock.json /app/assets/package.json /app/assets/node_modules ./npm/
COPY --from=build /app/assets/node_modules ./npm/node_modules

RUN curl -OL https://github.com/CycloneDX/cyclonedx-cli/releases/download/v0.25.1/cyclonedx-linux-x64 && \
    mv cyclonedx-linux-x64 /usr/local/bin/cyclonedx && \
    chmod u+x /usr/local/bin/cyclonedx

RUN git clone https://github.com/ideacrew/sbom_on_rails.git
RUN cd sbom_on_rails && bundle install

COPY sbom ./sbom

RUN cd sbom_on_rails && bundle exec ruby /sbom_generation/sbom/manifest/sbom.rb

# prepare release image
FROM alpine:3.19 AS app

# install runtime dependencies
RUN apk add --update bash openssl postgresql-client

EXPOSE 4000
ENV MIX_ENV=prod

# prepare app directory
RUN mkdir /app
WORKDIR /app

# copy release to app container
COPY --from=build /app/_build/${MIX_ENV}/rel/sectory ./
COPY --from=sbomber /sbom_generation/sbom/sectory-alpine.sbom ./
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app
CMD ["/app/bin/server"]