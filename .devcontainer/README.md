# Dev Container

> [!NOTE]
> This is a community supported feature

To assist with working on this repository, the community has configured a [dev container](https://containers.dev/) with the required tooling.

You can run this locally, or with [GitHub Codespaces](https://docs.github.com/en/codespaces/overview).

## Locally

> [!WARNING]  
> This has only been tested on macOS

### Prerequisites

- Docker

- Visual Studio Code

  - Dev Containers Extention

To launch locally, ensure the prerequisites are met, and then click the button below

[![Open in Dev Container](https://raw.githubusercontent.com/ministryofjustice/.devcontainer/refs/heads/main/contrib/badge.svg)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/ministryofjustice/cloud-platform-environments)

## GitHub Codespaces

> [!IMPORTANT]  
> GitHub Codespaces are not currently paid for by the Ministry of Justice and are subject to the quotas [here](https://docs.github.com/en/billing/managing-billing-for-your-products/managing-billing-for-github-codespaces/about-billing-for-github-codespaces#monthly-included-storage-and-core-hours-for-personal-accounts)

To launch a GitHub Codespace, click the button below

[![Open in Codespace](https://github.com/codespaces/badge.svg)](https://codespaces.new/ministryofjustice/cloud-platform-environments)

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
