FROM alpine/git AS clone_code

ARG GIT_COMMIT_SHA_CLIENT

WORKDIR /app

RUN git clone https://github.com/b310-digital/excalidraw.git . && \
    git checkout ${GIT_COMMIT_SHA_CLIENT} && \
    rm .env.production

FROM node:18 AS build

WORKDIR /opt/node_app

COPY --from=clone_code /app /opt/node_app

COPY .env.production .

RUN yarn --network-timeout 600000

ARG NODE_ENV=production

RUN yarn build:app:docker

FROM nginxinc/nginx-unprivileged:1.25-alpine-slim as production

COPY --from=build /opt/node_app/excalidraw-app/build /usr/share/nginx/html

HEALTHCHECK CMD wget -q -O /dev/null http://127.0.0.1:8080 || exit 1