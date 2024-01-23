# Dev Container

> This is a community supported feature

To assist in the development of `cloud-platform-environments`, the community have built a [dev container](https://containers.dev/) with the required tooling

## Prerequisites

- GitHub Codespaces

or

- Docker

- Visual Studio Code

  - Dev Containers Extention

## Running

### GitHub Codespaces

Launch from GitHub

### Locally

1. Ensure prerequisites are met

1. Clone repository

1. Open repository in Visual Studio Code

1. Reopen in container

## Tools

### AWS CLI

<https://aws.amazon.com/cli/>

### Cloud Platform CLI

<https://github.com/ministryofjustice/cloud-platform-cli>

### Kubernetes CLI

<https://kubernetes.io/docs/reference/kubectl/>

### Terraform Switcher

<https://tfswitch.warrensbox.com/>

### Trivy

<https://trivy.dev/>

## Support

As this is a community supported feature, help is offered on a best endeavour basis.

If you do need help, please post in [`#devcontainer`](https://moj.enterprise.slack.com/archives/C06DZ4F04JZ)

## Contribution Guidelines

- Check that an existing feature doesn't cover what you're trying to add

- Where possible reuse the existing practices from other features, utilising the shared library `devcontainer-utils`

- If you are creating a feature, add it to the feature testing matrix in the GitHub Actions workflow and ensure appropiate tests exist

## Maintainers

- [@jacobwoffenden](https://github.com/jacobwoffenden)

- [@Gary-H9](https://github.com/Gary-H9)
