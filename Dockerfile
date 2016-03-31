# Node.js and Containerbuddy
FROM gliderlabs/alpine:3.3

# install curl
RUN apk update && apk add \
    nodejs \
    make \
    python \
    git \
    curl \
    && rm -rf /var/cache/apk/*

# install sdc-nfs
COPY package.json /opt/nfs/
RUN cd /opt/nfs && npm install

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
