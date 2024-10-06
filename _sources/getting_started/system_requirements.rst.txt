System Requirements
===================

Before installing and using **reactor**, ensure that your system meets the following requirements. These prerequisites are essential for proper functionality of the CLI platform and for managing Kubernetes environments effectively.

Supported Operating Systems
---------------------------
- **Linux**: Any modern Linux distribution (e.g., Ubuntu, CentOS, Debian, Fedora).
- **macOS**: macOS 10.15 (Catalina) or later.
- **Windows**: Windows Subsystem for Linux (WSL) is required for running the CLI on Windows.

Required Tools and Dependencies
-------------------------------
To use **reactor**, the following tools and software must be installed:

- **Bash Shell**: Required for scripting and executing commands. Ensure that your system has Bash installed and available in your system path.

- **Git**: The Git version control system is required for managing repositories and interacting with the platform’s components. Make sure Git is installed and accessible from your command line.

  - Installation guide: [Git Installation](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

- **Python 3**: **reactor** requires Python 3 for running certain scripts and automating processes. Additionally, the **PyYAML** package is needed for parsing YAML configuration files.

  - Installation guide for Python 3: [Python Downloads](https://www.python.org/downloads/)
  - Install PyYAML: `pip install PyYAML`

- **Docker Engine**: Docker is essential for containerizing and managing applications within Kubernetes clusters. Ensure Docker Engine is installed and running on your system.

  - Installation guide: [Docker Installation](https://docs.docker.com/engine/install/)

- **Curl**: Curl is required for downloading resources from the web. This CLI tool enables easy interaction with various HTTP-based services.

  - Installation guide: [Curl Documentation](https://curl.se/)

- **OpenSSL**: The OpenSSL CLI tool is used for managing certificates and encryption protocols, necessary for secure communication and configuration within Kubernetes environments.

  - Installation guide: [OpenSSL Download](https://www.openssl.org/source/)

Ensure that all the above components are installed and configured properly before proceeding with the installation and setup of **reactor**.
