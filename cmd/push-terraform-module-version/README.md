# Push the latest terraform module version to be stored in the API

## Context

Pull requests (PRs) against the [environments repository][env-repo],
raised by users of the [MoJ Cloud Platform][cloud-platform],
have to be approved by the Cloud Platform team.

If these PRs make use of any "cloud-platform-terraform-\*" modules then it is important that the user is using the most up-to-date module version.

There is an action that queries the cloud platform [api][api-terraform-versions] and then verifies if the module in the PR is set to the latest module.


## This Action

The purpose of this action is to keep track of new terraform module releases. When a "cloud-platform-terraform-*" module releases a new version, this action will update the [api][api-terraform-versions] with this new version via a simple POST request.

## USAGE

Create a file in your repo called `.github/workflows/push-terraform-module-version.yaml` with the
following contents:

```
on:
  push:
    tags:
      - *

jobs:
  push-terraform-module-version:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: ministryofjustice/cloud-platform-environments/cmd/push-terraform-module-version@main
        env:
          API_URL: ${{ vars.TERRAFORM_MODULE_VERSIONS_API_URL }}
          API_KEY: ${{ secrets.TERRAFORM_MODULE_VERSIONS_API_KEY }}
          REPO_NAME: ${{ github.event.repository.name }}
          UPDATED_MODULE_VERSION: ${{ github.ref_name }}

```

`API_URL` is the url of the [api][api-terraform-versions] which tracks cloud platforms terrform module versions.
`API_KEY` the API route is protected for security
`REPO_NAME` is the name of the repo where we watch for new releases
`UPDATED_MODULE_VERSION` this is the new new release version to update the API with

[env-repo]: https://github.com/ministryofjustice/cloud-platform-environments
[cloud-platform]: https://github.com/ministryofjustice/cloud-platform
[api-terraform-versions]: https://github.com/ministryofjustice/cloud-platform-go-get-module
