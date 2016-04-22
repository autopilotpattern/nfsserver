# Based on the official Node.js 0.10 image, 
# because it's the easiest way to get that version
FROM node:0.10-slim

# Put our Node.js app definition in place
COPY package.json /opt/nfs/

# Install our Node.js app
# $buildDeps will be added for the `npm install`, then removed immediately after
# The resulting image layer will not include the size of the $buildDeps
RUN \
    buildDeps='git g++ make python' \
    runDeps='nfs-common ca-certificates curl vim' \
    && set -x \
    && apt-get update && apt-get install -y $buildDeps $runDeps --no-install-recommends \
    && cd /opt/nfs \
    && npm install \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge -y --auto-remove $buildDeps

# Add Containerpilot and set its configuration file path
ENV CONTAINERPILOT_VER 2.0.1
ENV CONTAINERPILOT file:///etc/containerpilot.json
RUN export CONTAINERPILOT_CHECKSUM=a4dd6bc001c82210b5c33ec2aa82d7ce83245154 \
    && curl -Lso /tmp/containerpilot.tar.gz \
        "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VER}/containerpilot-${CONTAINERPILOT_VER}.tar.gz" \
    && echo "${CONTAINERPILOT_CHECKSUM}  /tmp/containerpilot.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /usr/local/bin \
    && rm /tmp/containerpilot.tar.gz

# Put our configs and helper files in place
COPY etc /etc
COPY bin /usr/local/bin

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
