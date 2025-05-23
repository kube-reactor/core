#
#====================================================================
# Reactor Docker image
#
#
# Base image
#
ARG REACTOR_PARENT_IMAGE="ubuntu:22.04"
FROM ${REACTOR_PARENT_IMAGE}
#
# Computer Processing Chip architecture
#
ARG REACTOR_ARCHITECTURE="amd64"
#
# Dockerfile arguments
#
ARG REACTOR_USER_NAME=reactor
ARG REACTOR_USER_UID=1000
ARG REACTOR_DOCKER_GID=135
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
# Docker installation
#
RUN apt-get update -y \
  && apt-get upgrade -y \
  && apt-get install -y lsb-release software-properties-common apt-transport-https apt-utils sudo curl gnupg2 git \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu/ $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

RUN apt-get update -y \
  && apt-get install -y docker-ce \
  && rm -rf /var/lib/apt/lists/*
#
# User initialization
#
ENV HOME_DIR=/home/${REACTOR_USER_NAME}

RUN ((getent group ${REACTOR_DOCKER_GID} && newgrp docker) || groupmod --gid ${REACTOR_DOCKER_GID} docker) \
  && groupadd -f --system --gid ${REACTOR_USER_UID} ${REACTOR_USER_NAME} \
  && useradd --system --create-home \
  --home-dir ${HOME_DIR} \
  --shell /bin/bash \
  --uid ${REACTOR_USER_UID} \
  --gid ${REACTOR_USER_NAME} \
  --groups root,sudo,docker,$(getent group ${REACTOR_DOCKER_GID} | cut -d: -f1) \
  ${REACTOR_USER_NAME} \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && echo 'export PATH="/reactor/bin:$PATH"' >> /etc/bash.bashrc
#
#====================================================================
# Application configuration
#

#
# Reactor directory
#
COPY --chown=${REACTOR_USER_NAME}:${REACTOR_USER_NAME} ./ /reactor
VOLUME /reactor

#
# Execution gateway
#
USER ${REACTOR_USER_NAME}
WORKDIR ${HOME_DIR}

#
# Install dependencies
#
ENV __bin_dir=/reactor/bin
RUN /reactor/bin/core/loader.sh

ENTRYPOINT ["/reactor/bin/core/exec.sh"]
