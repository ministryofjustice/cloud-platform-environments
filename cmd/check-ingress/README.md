# Check ingress weight annotation

A GitHub Action to check if the namespace in a PR contains a Kubernetes ingress resource without the required annotation. If so, the action will fail.

This helps members of the Cloud Platform team identify quickly if a PR needs action.

## An example

Here is a really basic example of the GitHub Action working in the Cloud Platform [environments](https://github.com/ministryofjustice/cloud-platform-environments/) repository.

```yaml
name: Check ingress weighting annotation

on:
  pull_request:
    paths:
      - "namespaces/live.cloud-platform.service.justice.gov.uk/**"

env:
  # GITHUB_OAUTH_TOKEN created manually by the cloud-platform-bot-user in last pass.
  GITHUB_OAUTH_TOKEN: ${{ secrets.CHECK_GITHUB_TEAM }}

jobs:
  check-ingress-weighting:
    runs-on: ${{ matrix.os }}

    strategy:
      matrix:
        os: [ubuntu-latest]

    steps:
      - name: Checkout PR code
        uses: actions/checkout@master

      - name: Does live-1 namespace have ingress weighting
        id: review_pr
        uses: ministryofjustice/cloud-platform-environments/cmd/check-ingress@main
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      # If the user isn't permitted to make the change, write a comment in the issue.
      - name: Create comment in the PR
        uses: peter-evans/create-or-update-comment@v1

        if: failure()
        with:
          issue-number: ${{ github.event.pull_request.number }}
          body: |
            The namespace in this PR contains a live-1 ingress resource that doesn't have the correct weighting annotation.
```

## How to run locally

To run the application locally, you must have the following:

- An envvar named `GITHUB_REF` that contains the reference number of a PR e.g. 3321 (is the number of the PR).

```bash
export GITHUB_REF=refs/pull/5504/merge
```

- A GITHUB personal access token with permission to the MoJ org.

Then you can run:

```bash
go run check-ingress.go
```
