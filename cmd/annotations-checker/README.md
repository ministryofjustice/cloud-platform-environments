# This project validates Kubernetes namespace YAML files in a GitHub pull request. It checks the following:

1. The file is a Kubernetes Namespace definition
2. The `team-name` annotation exists within the organization
3. The `source-code` annotation points to a public repository.

## Testing the Program

### Testing Locally

1. ```bash
    clone the repo
   ```

2. **Set Up Environment Variable:**
   Ensure you have a GitHub token with the necessary permissions.

   ```bash
   export GITHUB_TOKEN=your_github_token
   ```

3. **Build the Docker Image:**

   ```bash
   docker build -t annotations-checker .
   ```

4. **Run the Docker Container**
   ```bash
   docker run -e GITHUB_TOKEN=$YOUR_GITHUB_TOKEN annotations checker
   ```

### Using GitHub Actions

The GitHub Actions workflow will automatically run the checker for pull requests to the `main` and `annotations-checker` branches.

1.  **Create a GitHub Actions workflow**
    Create a file `.github/workflows/validate-annotations.yml` with the following content:

    ```yaml
    name: Annotations Checker

    on:
      pull_request:
      branches:
        - main
          - annotations-checker

    jobs:
      validate-annotations:
      name: Validate Annotations
      runs-on: ubuntu-latest
      steps:
        - name: Check out code
          uses: actions/checkout@v3

        - name: Build Docker image
          run: docker build -t annotations-checker .

        - name: Run Validation in Docker Container
          env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          run: docker run --rm -e GITHUB_TOKEN=${{ secrets.GITHUB_TOKEN }} annotations-checker
    ```

TODOs:

1. check that diff_rul is accessed correctly from the action
1. make sure that the action _only_ runs when it is an update or an addition (not for deletions), you might need to play around with the string.Contains()
1. write tests:
    - valid test passes passing a raw diff for a valid pr
    - invalid pr fails containing incorrect team name
    - invalid pr fails containing incorrect source code repo (repo doesnt exist)
1. update readme
