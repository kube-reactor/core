#
#====================================================================
# Zimagi Docker image
#
#
# Base image
#
ARG REACTOR_PARENT_IMAGE="ubuntu:22.04"
FROM ${REACTOR_PARENT_IMAGE}
#
# Dockerfile arguments
#
ARG REACTOR_USER_UID=1000
ARG REACTOR_USER_PASSWORD="reactor"
#
#====================================================================
# Core system configuration
#
#
# Core environment variables
#
ENV LANG=C.UTF-8
ENV PYTHONUNBUFFERED=1
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
#
# Shell environment
#
SHELL ["/bin/bash", "--login", "-c"]
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
#
# Package repository management
#
COPY ./docker/packages.core.txt /root/packages.core.txt
RUN apt-get update -y \
  && apt-get upgrade -y \
  && sed '/^\s*\#.*$/d' /root/packages.core.txt | xargs -r apt-get install -y --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu/ $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
#
# System dependencies
#
COPY ./docker/packages.app.txt /root/packages.app.txt
RUN apt-get update -y \
  && sed '/^\s*\#.*$/d' /root/packages.app.txt | xargs -r apt-get install -y --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

#
# Python packages
#
COPY ./docker/requirements.txt /root/requirements.txt
RUN pip3 install --no-cache-dir -r /root/requirements.txt
#
# User initialization
#
ENV HOME_DIR=/home/reactor

RUN groupadd -f --system --gid ${REACTOR_USER_UID} reactor \
  && useradd --system --create-home \
  --home-dir ${HOME_DIR} \
  --shell /bin/bash \
  --uid ${REACTOR_USER_UID} \
  --gid reactor \
  --groups sudo \
  reactor \
  && echo "reactor:${REACTOR_USER_PASSWORD}" | chpasswd
#
#====================================================================
# Application configuration
#
#
# Application environment variables
#
ENV REACTOR_DIR="/reactor"
ENV SCRIPT_DIR="${REACTOR_DIR}/scripts"

ENV PATH="${SCRIPT_DIR}:${PATH}"
#
# Reactor directory
#
COPY --chown=reactor:reactor ./ ${REACTOR_DIR}
VOLUME ${REACTOR_DIR}
#
# Execution gateway
#
USER reactor
WORKDIR ${HOME_DIR}
ENTRYPOINT ["reactor-exec"]
