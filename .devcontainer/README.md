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

### Cloud Platform CLI

<https://github.com/ministryofjustice/cloud-platform-cli>

### Kubernetes CLI

<https://kubernetes.io/docs/reference/kubectl/>

## Authenticating with Cloud Platform

1. Log into [Cloud Platform's Kuberos](https://login.cloud-platform.service.justice.gov.uk/)

1. Obtain the command from “Authenticate Manually”

1. Replace the email shown after `kubectl config set-credentials` with `auth0`

   ```bash
   kubectl config set-credentials "auth0" \
     --auth-provider=oidc \
     --auth-provider-arg=client-id="..." \
     --auth-provider-arg=client-secret="..." \
     --auth-provider-arg=id-token="..." \
     --auth-provider-arg=refresh-token="..." \
     --auth-provider-arg=idp-issuer-url="https://justice-cloud-platform.eu.auth0.com/"
   ```

1. Run the modified command

1. Optionally you can set a namespace

   ```bash
   kubectl config set-context --current --namespace=${NAMESPACE}
   ```

## Support

As this is a community supported feature, help is offered on a best endeavour basis.

If you do need help, please post in [`#devcontainer-community`](https://moj.enterprise.slack.com/archives/C06DZ4F04JZ)

## Contribution Guidelines

- If you wish to add a feature, check in with [`#devcontainer-community`](https://moj.enterprise.slack.com/archives/C06DZ4F04JZ) to see if its worth publishing centrally, otherwise

- Check that an existing feature doesn't cover what you're trying to add

- Where possible reuse the existing practices from other features, utilising the shared library `/usr/local/bin/devcontainer-utils`

## Maintainers

- [@ministryofjustice/devcontainer-community](https://github.com/orgs/ministryofjustice/teams/devcontainer-community)
