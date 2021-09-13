# Rbac permissions check

A GitHub Action to check if a user is allowed to modify a [cloud-platform-environments](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/env-create.html#namespace-yaml-files) namespace.

When a user creates a pull request on the [cloud-platform-environments](https://github.com/ministryofjustice/cloud-platform-environments/) repository this check is triggered confirming the users access. If the user is in the relevant GitHub team specified in the namespaces [rbac file](https://github.com/ministryofjustice/cloud-platform-environments/blob/main/namespaces/live-1.cloud-platform.service.justice.gov.uk/abundant-namespace-dev/01-rbac.yaml) the check will pass, However if the user isn't a member of the team the Action will fail and a message will be posted into the comments of the PR.

This ensures only team members can modify, create and delete namespaces they have ownership of.

## An example

Here is a really basic example of the GitHub Action working in the Cloud Platform [environments](https://github.com/ministryofjustice/cloud-platform-environments/) repository.

```yaml
name: Check if user can amend namespace

on:
  pull_request

env:
  PR_OWNER: ${{ github.event.pull_request.user.login }}
  BRANCH: ${{ github.head_ref }}
  GITHUB_OAUTH_TOKEN: ${{ secrets.CHECK_GITHUB_TEAM }}

jobs:
  rbac-permissions-check:
    runs-on: ${{ matrix.os }}

    strategy:
      matrix:
        os: [ubuntu-latest]

    steps:
      - name: Checkout PR code
        uses: actions/checkout@master

      - name: Get all files changed in PR
        id: files
        uses: jitterbit/get-changed-files@v1
        with:
          format: 'csv'

      - name: Output all changes to a file
        run: |
          mapfile -d ',' -t added_modified_files < <(printf '%s,' '${{ steps.files.outputs.all }}')
          for added_modified_file in "${added_modified_files[@]}"; do
            if [[ "${added_modified_file}" == *"live"* ]]; then
              echo "${added_modified_file}" | awk -F/ '{print $3}' >> files
            fi
          done

      - name: Check the PR owner is in the correct rbac group
        id: review_pr
        uses: ministryofjustice/github-actions/env-permissions-check@add-rbac-check
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## How to run locally

To run the application locally, you must have the following:
- A personal access token, with permission to view your organisation (this will require you to setup and enable SSO).
- An environment variable set called `GITHUB_OAUTH_TOKEN` with the value of your personal access token.
- An environment variable set called `PR_OWNER` that contains the valid username of a GitHub user.
- A file containing namespaces that exist i.e. `abundant-namespace-dev`.

Then you can run:

```bash
go run main.go
```

## How to run tests

To run the tests in this repository you must have a personal access token, with permission to view your organisation (this will require you to setup and enable SSO).

You must set an environment variable called `TEST_GITHUB_ACCESS`.

Then you can run:

```bash
go test -v ./...
```
