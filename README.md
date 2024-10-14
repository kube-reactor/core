# Reactor

The Reactor project is a modular and extensible command-line interface (CLI) platform for **Kubernetes development and management**. It is designed to simplify the process of deploying, managing, and scaling applications within Kubernetes environments. It is designed to allow the creation of template projects that unify the project structure of complex multi app Kubernetes platforms managed by ArgoCD between local development environments and remote hosting environments; staging, production, etc...

## Motivation and Goals

Developing Kubernetes environments with integrated applications can be challenging. Tools like ArgoCD provide great ways to implement a GitOps process to automatically manage Kubernetes applications in remote cloud environments through CI/CD but local development is still challenging.  This is particularly true when there are many applications that need to work together or a platform needs to be distributed with bundled management applications, such as database editors and file volume explorers.  Many developers resort to using Docker Compose locally due to simplicity, but this creates a divergence between the development and production environments which can lead to headaches in production systems.  It is also impossible to develop Kubernetes native applications with this approach.

Our goal is to create an easy to develop project environment that unifies the development process with an automated GitOps CI/CD workflow for remote environments using the exact same project structure.  We build off of Minikube and ArgoCD to provide a running local Kubernetes environment and graphical application management system that is automatically managed by an extensible CLI toolset that emulates the ease of the Docker Compose system for developing clustered services.  We also focus on integrating established and popular technologies like Terraform to provision all of the ArgoCD project and application definitions, which allows us to easily build integrated cloud deployment systems around the framework within the projects.

We also focus on ensuring that Helm chart usage within the project structure is as easy as possible so the Reactor system allows you to define environment variables for various environments within public or private environment files that can be directly interpolated into the values files of Helm charts and automatically created Kubernetes config maps and secrets shared in the project namespaces.  Applications are separated into project directories and automatically provisioned and managed in an easy to use system that gets Kubernetes development much closer to the Docker Compose experience, while unifying all of the cluster project environments, which ensures an easier production deployment and management experience.

## Key Features

- **Modular Architecture**: Customize your projects by adding or overriding commands and utilities based on your specific needs.  Reactor implements a hook system so it is easy to extend existing functionality
- **Easy to Develop**: No need to learn or know programming languages like Python or Go as everything is built off of Bash shell scripting.  You can easily write shell scripts and functions that use a central environment to make building custom workflows easy.  Or you can integrate scripts written in your favorite programming language to extend the platform.
- **Integrated ArgoCD Management**: Built to integrate seamlessly with ArgoCD for efficient application management with a nice graphical interface for exploring the deployed resources.
- **Automation & CI/CD**: The same project setup that you use for development can easily be hooked up to automated CI/CD workflows to encourage unity between environments.  This way you end up with a single platform repository for your cluster with application repositories that can automatically deploy updates from application repositories without developers needing to do anything but push commits and merge pull requests to manage their cluster applications.
- **Easy Application Configuration and Testing**: Directly interpolate environment variables into YAML based config map and secret resource definitions, Helm chart values files, and Kubernetes resource manifests.  You can also create values files specific to each environment within each application folder that are automatically searched to separate configurations.

## Documentation

For detailed setup instructions, core concepts, usage examples, and advanced configurations, please visit the official documentation site:

[Official Documentation](https://kube-reactor.github.io/core/)

## Getting Started

To quickly get started with **reactor**, follow the installation guide in the documentation:

[Installation Guide](https://kube-reactor.github.io/core/getting_started/readme.html)

## Contributing

We welcome contributions! Please review the contribution guidelines on how to get involved:

[Contributing Guide](https://kube-reactor.github.io/core/community_support/readme.html)

## License

**Reactor** is released under the **Apache 2.0** license. For more information, see the `LICENSE` file.
