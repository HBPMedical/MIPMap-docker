#                    Copyright (c) 2016-2016
#   Data Intensive Applications and Systems Labaratory (DIAS)
#            Ecole Polytechnique Federale de Lausanne
#
#                      All Rights Reserved.
#
# Permission to use, copy, modify and distribute this software and its
# documentation is hereby granted, provided that both the copyright notice
# and this permission notice appear in all copies of the software, derivative
# works or modified versions, and any portions thereof, and that both notices
# appear in supporting documentation.
#
# This code is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. THE AUTHORS AND ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE
# DISCLAIM ANY LIABILITY OF ANY KIND FOR ANY DAMAGES WHATSOEVER RESULTING FROM THE
# USE OF THIS SOFTWARE.

FROM openjdk:8u131-jre-alpine
MAINTAINER Lionel Sambuc <lionel.sambuc@epfl.ch>

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
ARG EXPORT_CMD="-csv"
ENV EXPORT_CMD=$EXPORT_CMD
ARG EXPORT_PATH="/opt/target"
ENV EXPORT_PATH=$EXPORT_PATH

# Install Dockerize
ENV DOCKERIZE_VERSION=v0.4.0

RUN apk update && apk add bash wget \
    && wget -O /tmp/dockerize.tar.gz https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
    && tar -C /usr/local/bin -xzvf /tmp/dockerize.tar.gz \
    && apk del wget \
    && rm -rf /var/cache/apk/* /tmp/*

# Installs MIPMap
COPY MIPMapReduced.jar /opt/
COPY docker/mipmap_db.properties.tmpl /etc/mipmap/
COPY docker/run.sh /opt/run-mipmap.sh

WORKDIR /opt

ENTRYPOINT ["/opt/run-mipmap.sh"]

CMD ["$EXPORT_CMD", "$EXPORT_PATH"]

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="hbpmip/mipmap" \
      org.label-schema.description="Docker image for running MIPMap" \
      org.label-schema.url="https://github.com/HBPMedical/MIPMap-docker" \
      org.label-schema.vcs-type="git" \
      org.label-schema.vcs-url="https://github.com/HBPMedical/MIPMap" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version="$VERSION" \
      org.label-schema.vendor="WIM AUEB" \
      org.label-schema.docker.dockerfile="Dockerfile" \
      org.label-schema.schema-version="1.0"
