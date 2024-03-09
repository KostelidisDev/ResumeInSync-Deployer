FROM node:16 as build

RUN apt-get update && apt-get install -y git && apt-get clean

WORKDIR /opt/sources

ARG WEB_APP_PROTOCOL
ARG WEB_APP_IP
ARG WEB_APP_PORT
ARG API_APP_PROTOCOL
ARG API_APP_IP
ARG API_APP_PORT
ARG API_APP_PATH="/api"
ARG API_APP_USERNAME
ARG API_APP_PASSWORD

ARG RESUMEINSYNC_UI_REPOSITORY=""
ARG RESUMEINSYNC_UI_BRANCH=""
RUN git clone --branch ${RESUMEINSYNC_UI_BRANCH} ${RESUMEINSYNC_UI_REPOSITORY} resumeinsync-ui \
    && cd resumeinsync-ui \
    && yarn install \
    && yarn build:prod \
    && mv /opt/sources/resumeinsync-ui/public /opt/public \
    && cd .. \
    rm -fr resumeinsync-ui

FROM nginx:1.20
COPY --from=build /opt/public /usr/share/nginx/html