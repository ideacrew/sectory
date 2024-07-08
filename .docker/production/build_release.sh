#!/bin/bash

GIT_SHA=`git rev-parse HEAD`

docker buildx build -f .docker/production/Dockerfile.alpine-inventory -t sectory-alpine-inventory:$GIT_SHA .
docker sbom --output sectory-alpine-inventory.sbom --format cyclonedx-json sectory-alpine-inventory:$GIT_SHA 

docker buildx build -f .docker/production/Dockerfile -t sectory-alpine:$GIT_SHA --build-arg COMMIT_SHA=$GIT_SHA .
docker container create --name sectory-alpine-container-$GIT_SHA sectory-alpine:$GIT_SHA
docker container cp sectory-alpine-container-$GIT_SHA:/app/sectory-alpine.sbom ./sectory-alpine.sbom
docker container rm -f sectory-alpine-container-$GIT_SHA