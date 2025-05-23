Installation
============

This guide will walk you through two approaches to install **Reactor**, the CLI tool for **Kubernetes development and management**. Depending on your environment and preferences, you can either install Reactor as a **Kubectl Krew plugin** or as a **local script library** that you can add to your system `PATH`.

Option 1: Install Reactor as a Kubectl Krew Plugin
--------------------------------------------------

**Krew** is a plugin manager for `kubectl` that makes it easy to discover and install kubectl plugins. Installing **Reactor** as a Krew plugin integrates it seamlessly with `kubectl`, allowing you to develop your Kubernetes cluster applications using the familiar Kubernetes CLI.

Prerequisites
^^^^^^^^^^^^^

- You must have `kubectl` installed and configured.
- Krew must be installed on your system. Follow the Krew installation instructions here: `https://krew.sigs.k8s.io/docs/user-guide/setup/install/`.

Note: We have plans to add **reactor** to the official Krew plugin registry but until we complete that process we have created a custom plugin registry in the Zimagi GitHub organization.

Installation Steps
^^^^^^^^^^^^^^^^^^

1. Install Reactor using Krew by running the following command:

   .. code-block:: bash

      # Copy, paste, and run the following command sequence into your terminal
      (
        kubectl krew index add reactor https://github.com/kube-reactor/krew-index.git &&
        kubectl krew install reactor/reactor
      )

2. Once the installation is complete, verify that Reactor is installed:

   .. code-block:: bash

      kubectl reactor --help

Reactor is now installed as a `kubectl` plugin and can be accessed using the `kubectl reactor` command. For more information on how to use Reactor with kubectl, refer to the usage section in this documentation.

Option 2: Install Reactor as a Local Script Library
---------------------------------------------------

Alternatively, you can install **Reactor** as a standalone script library and add it to your system `PATH` for direct usage. This method provides flexibility for those who prefer managing tools outside of `kubectl` and want to use Reactor as a standalone CLI.

Prerequisites
^^^^^^^^^^^^^

- Ensure that you have `curl` installed for downloading the Reactor CLI.
- Ensure that your system `PATH` is properly configured to include additional binaries or scripts.

Installation Steps
^^^^^^^^^^^^^^^^^^

1. Download the Reactor CLI scripts to a location on your machine:

   .. code-block:: bash

      # Copy, paste, and run the following command sequence into your terminal
      # You can find the latest reactor release here: https://github.com/kube-reactor/core/releases
      (
        REACTOR_VERSION=0.1.2 &&
        set -x && mkdir -p "${HOME}/reactor" && cd "${HOME}/reactor" &&
        curl -fsSLO https://github.com/kube-reactor/core/releases/download/${REACTOR_VERSION}/reactor.tar.gz &&
        tar -zxvf reactor.tar.gz
      )

2. Add the installation bin directory to your system `PATH` (if not already done):

   .. code-block:: bash

      # Add the following line to your ~/.bashrc or ~/.profile
      export PATH="${HOME}/reactor/bin:${PATH}"

3. Verify the installation by checking the Reactor CLI version:

   .. code-block:: bash

      reactor --version

Reactor is now installed as a standalone CLI tool and can be run using the `reactor` command from any terminal session.

Core Environment Variables
^^^^^^^^^^^^^^^^^^^^^^^^^^

 * **LOG_LEVEL**: Logging level 1 _(alerts only)_ - 7 _(debugging)_

 * **REACTOR_ENVIRONMENT**: Environment name _(default **local**)_
 * **REACTOR_PROJECT_NAME**: Reactor project name _(when in core or template development modes)_

 * **DEFAULT_REACTOR_TEMPLATE_URL**: Default template to use in create command _(git url)_
 * **DEFAULT_REACTOR_TEMPLATE_REMOTE**: Default template to use in create command _(git remote)_
 * **DEFAULT_REACTOR_TEMPLATE_REFERENCE**: Default template to use in create command _(get branch or tag)_
 * **PROJECT_TEMPLATE_DIRECTORY**: Specific template directory _(used in test command)_

 * **REACTOR_DOCKER_SOCKET_FILE**: Docker socket file location if different than default for Linux or Mac
 * **REACTOR_RUNTIME_IMAGE**: Runtime image name and version for reactor image command
 * **REACTOR_DOCKER_RUN_ARGS**: Array of optional arguments to pass to docker run command execution
 * **HOME_SHARES**: Array of directories and files to share with Docker runtime container
