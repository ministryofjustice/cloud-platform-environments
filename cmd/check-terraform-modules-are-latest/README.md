# Check "cloud-platform-terraform-*" modules are the latest versions 

Pull requests (PRs) against the [environments repository][env-repo],
raised by users of the [MoJ Cloud Platform][cloud-platform],
have to be approved by the Cloud Platform team.

If these PRs make use of any "cloud-platform-terraform-*" modules then it is important that the user is using the most up-to-date module version.

This Github Action marks PRs as failed if they are not using the latest module version.

The action queries the cloud platform [api][api-terraform-versions] which verifies if the module in the PR is set to the latest module.

## USAGE

Create a file in your repo called `.github/workflows/check-terraform-modules-are-latest.yml` with the
following contents:

```
on:
  pull_request:
    types: [opened, edited, reopened, synchronize]

jobs:
  check-terraform-modules-are-latest:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: ministryofjustice/github-actions/check-terraform-modules-are-latest@main
        env:
          REPO_NAME: cloud-platform-environments
          API_URL: ${{ env.API_URL }}
          PR_NUMBER: ${{ github.event.number }}
```

`API_URL` is the url of the [api][api-terraform-versions] which tracks cloud platforms terrform module versions.
`REPO_NAME` is the name of the repo where we watch for prs eg. [cloud-platform-environments][env-repo]
`PR_NUMBER` this is needed so the action knows where to pull the diff containing the changes from

[env-repo]: https://github.com/ministryofjustice/cloud-platform-environments
[cloud-platform]: https://github.com/ministryofjustice/cloud-platform
[api-terraform-versions]: https://github.com/ministryofjustice/cloud-platform-go-get-module

