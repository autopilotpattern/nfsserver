# Based on the official Node.js 0.10 image, 
# because it's the easiest way to get that version
FROM node:0.10-slim

# Build-time metadata as defined at http://label-schema.org
# with added usage described in https://microbadger.com/#/labels
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.name="Autopilot Pattern NFS Server" \
    org.label-schema.url="https://github.com/autopilotpattern/nfsserver" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-url="https://github.com/autopilotpattern/nfsserver"

# Put our Node.js app definition in place
COPY package.json /opt/nfs/

# Install our Node.js app
# $buildDeps will be added for the `npm install`, then removed immediately after
# The resulting image layer will not include the size of the $buildDeps
RUN \
    buildDeps='git g++ make python' \
    runDeps='nfs-common ca-certificates curl vim zip' \
    && set -x \
    && apt-get update && apt-get install -y $buildDeps $runDeps --no-install-recommends \
    && cd /opt/nfs \
    && npm install \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge -y --auto-remove $buildDeps

# Add ContainerPilot and its configuration
# Releases at https://github.com/joyent/containerpilot/releases
ENV CONTAINERPILOT_VER 2.3.0
ENV CONTAINERPILOT file:///etc/containerpilot.json

RUN export CONTAINERPILOT_CHECKSUM=ec9dbedaca9f4a7a50762f50768cbc42879c7208 \
    && curl --retry 7 --fail -Lso /tmp/containerpilot.tar.gz \
         "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VER}/containerpilot-${CONTAINERPILOT_VER}.tar.gz" \
    && echo "${CONTAINERPILOT_CHECKSUM}  /tmp/containerpilot.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /usr/local/bin \
    && rm /tmp/containerpilot.tar.gz

# Put our configs and helper files in place
COPY etc /etc
COPY bin /usr/local/bin

# Install Consul
# Releases at https://releases.hashicorp.com/consul
RUN export CONSUL_VERSION=0.6.4 \
    && export CONSUL_CHECKSUM=abdf0e1856292468e2c9971420d73b805e93888e006c76324ae39416edcf0627 \
    && curl --retry 7 --fail -vo /tmp/consul.zip "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" \
    && echo "${CONSUL_CHECKSUM}  /tmp/consul.zip" | sha256sum -c \
    && unzip /tmp/consul -d /usr/local/bin \
    && rm /tmp/consul.zip \
    && mkdir /config

# Create empty directories for Consul config and data
RUN mkdir -p /etc/consul \
    && mkdir -p /var/lib/consul

# Create a directory required by rpcbind
RUN mkdir -p /run/sendsigs.omit.d

EXPOSE 111 1892 2049

# define the volume for the NFS export
VOLUME /exports

CMD [ "/usr/local/bin/containerpilot", \
    "node", \
    "/opt/nfs/node_modules/sdc-nfs/server.js", \
	"-f", \
	"/etc/sdc-nfs.json"]
