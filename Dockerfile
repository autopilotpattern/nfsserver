# Based on the official Node.js 0.10 image, 
# because it's the easiest way to get that version and the image is small enough
FROM node:0.10-slim

# Put our Node.js app definition in place
COPY package.json /opt/nfs/

# Install our Node.js app
# $buildDeps will be added for the `npm install`, then removed immediately after
# the resulting image layer will not include the size of the $buildDeps
RUN \
    buildDeps='git g++ make python' \
    runDeps='ca-certificates curl' \
    && set -x \
    && apt-get update && apt-get install -y $buildDeps $runDeps --no-install-recommends \
    && cd /opt/nfs \
    && npm install \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge -y --auto-remove $buildDeps

# Add Containerbuddy and its configuration
ENV CONTAINERBUDDY_VER 1.2.1
ENV CONTAINERBUDDY_CHECKSUM aca04b3c6d6ed66294241211237012a23f8b4f20
ENV CONTAINERBUDDY file:///etc/containerbuddy.json

RUN export CB_SHA1=aca04b3c6d6ed66294241211237012a23f8b4f20 \
    && curl -Lso /tmp/containerbuddy.tar.gz \
         "https://github.com/joyent/containerbuddy/releases/download/${CONTAINERBUDDY_VER}/containerbuddy-${CONTAINERBUDDY_VER}.tar.gz" \
    && echo "${CONTAINERBUDDY_CHECKSUM}  /tmp/containerbuddy.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerbuddy.tar.gz -C /bin \
    && rm /tmp/containerbuddy.tar.gz
