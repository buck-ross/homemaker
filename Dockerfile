FROM alpine:latest

# Define container metadata:
LABEL version="1.0.0" \
      maintainer="haximilian@gmail.com" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.version="1.0.0-ALPHA.0" \
      org.label-schema.name="homemaker" \
      org.label-schema.description="The official Homemaker container" \
      org.label-schema.vcs-url="https://github.com/haximilian/homemaker" \
      org.label-schema.vendor="Haximilian" \
      org.label-schema.docker.cmd="docker run -it haximilian/homemaker:1.0.0-ALPHA.0"

# Install bash:
RUN apk update; apk add bash

# Copy Homemaker scripts:
COPY homemaker.sh /root/homemaker.sh
COPY .homemaker.d /root/.homemaker.d
