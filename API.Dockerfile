FROM maven:3-openjdk-8-slim as dependencies

RUN apt-get update && apt-get install -y git && apt-get clean

WORKDIR /opt/sources

ARG LINKEDIN_DATA_IMPORTER_REPOSITORY=""
ARG LINKEDIN_DATA_IMPORTER_BRANCH=""
RUN git clone --branch ${LINKEDIN_DATA_IMPORTER_BRANCH} ${LINKEDIN_DATA_IMPORTER_REPOSITORY} linkedin-data-importer \
    && cd linkedin-data-importer \
    && mvn install \
    && cd .. \
    rm -fr linkedin-data-importer


ARG ZOTERO_PUBLICATIONS_IMPORTER_REPOSITORY=""
ARG ZOTERO_PUBLICATIONS_IMPORTER_BRANCH=""
RUN git clone --branch ${ZOTERO_PUBLICATIONS_IMPORTER_BRANCH} ${ZOTERO_PUBLICATIONS_IMPORTER_REPOSITORY} zotero-publications-importer \
    && cd zotero-publications-importer \
    && mvn install \
    && cd .. \
    rm -fr zotero-publications-importer


FROM dependencies as build
ARG RESUMEINSYNC_API_REPOSITORY=""
ARG RESUMEINSYNC_API_BRANCH=""
RUN git clone --branch ${RESUMEINSYNC_API_BRANCH} ${RESUMEINSYNC_API_REPOSITORY} resumeinsync-api \
    && cd resumeinsync-api \
    && mvn package \
    && mv ./resumeinsync-api/target/resumeinsync-api-RELEASE.jar /opt/resumeinsync-api-RELEASE.jar \
    && cd .. \
    rm -fr resumeinsync-api

FROM openjdk:8u312-jre-slim

RUN apt-get update \
    && apt-get install -y \
    locales \
    locales-all \
    mime-support \
    && apt-get clean

COPY --from=build /opt/resumeinsync-api-RELEASE.jar /opt/gr/ihu/ict/resumeinsync-api.jar

ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV TZ="Europe/Athens"
ENV ACTIVE_PROFILE="production"
ENV DATABASE_USERNAME=""
ENV DATABASE_PASSWORD=""
ENV DATABASE_URL=""
ENV CLIENT_ID=""
ENV CLIENT_SECRET=""
ENV SIGNING_KEY=""
ENV VERIFIER_KEY=""
ENV RESOURCE_ID="ResumeInSync Resource"
ENV ACCESS_TOKEN_DURATION="21600"
ENV REFRESH_TOKEN_DURATION="86400"

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/opt/gr/ihu/ict/resumeinsync-api.jar", "--spring.profiles.active=${ACTIVE_PROFILE}"]