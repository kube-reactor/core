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
# Reactor core Python packages
#
COPY ./requirements.txt /root/requirements.txt
RUN pip3 install --no-cache-dir -r /root/requirements.txt
#
# Management utilities
#
RUN curl -sLo "/usr/local/bin/minikube" \
  "https://storage.googleapis.com/minikube/releases/v1.34.0/minikube-linux-${REACTOR_ARCHITECTURE}" \
  && chmod 755 "/usr/local/bin/minikube"

RUN curl -sLo "/usr/local/bin/kubectl" \
  "https://dl.k8s.io/release/v1.31.0/bin/linux/${REACTOR_ARCHITECTURE}/kubectl" \
  && chmod 755 "/usr/local/bin/kubectl"

RUN curl -sLo "/tmp/helm.tar.gz" \
  "https://get.helm.sh/helm-v3.15.4-linux-${REACTOR_ARCHITECTURE}.tar.gz" \
  && tar -xzf "/tmp/helm.tar.gz" -C "/tmp" \
  && mv "/tmp/linux-${REACTOR_ARCHITECTURE}/helm" "/tmp/helm" \
  && rm -f "/tmp/helm.tar.gz" \
  && rm -Rf "/tmp/linux-${REACTOR_ARCHITECTURE}" \
  && install "/tmp/helm" /usr/local/bin \
  && rm -f "/tmp/helm"

RUN curl -sLo "/usr/local/bin/argocd" \
  "https://github.com/argoproj/argo-cd/releases/download/v2.11.8/argocd-linux-${REACTOR_ARCHITECTURE}" \
  && chmod 755 "/usr/local/bin/argocd"
#
# User initialization
#
ENV HOME_DIR=/home/${REACTOR_USER_NAME}

RUN groupmod --gid ${REACTOR_DOCKER_GID} docker \
  && groupadd -f --system --gid ${REACTOR_USER_UID} ${REACTOR_USER_NAME} \
  && useradd --system --create-home \
  --home-dir ${HOME_DIR} \
  --shell /bin/bash \
  --uid ${REACTOR_USER_UID} \
  --gid ${REACTOR_USER_NAME} \
  --groups sudo,docker \
  ${REACTOR_USER_NAME} \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && echo 'alias reactor="reactor-exec"' >> /etc/bash.bashrc
#
#====================================================================
# Application configuration
#
#
# Application environment variables
#
ENV REACTOR_LOCAL="0"

ENV REACTOR_DIR="/reactor"
ENV SCRIPT_DIR="${REACTOR_DIR}/scripts"
ENV BUILD_DIR="${REACTOR_DIR}/project"

ENV PATH="${SCRIPT_DIR}:${PATH}"
#
# Reactor directory
#
COPY --chown=${REACTOR_USER_NAME}:${REACTOR_USER_NAME} ./ ${REACTOR_DIR}
VOLUME ${REACTOR_DIR}
#
# Project customization
#
RUN test ! -f ${BUILD_DIR}/requirements.txt \
  || pip3 install --no-cache-dir -r ${BUILD_DIR}/requirements.txt

RUN test ! -x ${BUILD_DIR}/install.sh \
  || ${BUILD_DIR}/install.sh
#
# Execution gateway
#
USER ${REACTOR_USER_NAME}
WORKDIR ${HOME_DIR}
ENTRYPOINT ["reactor-exec"]
