# Generate Deprecated Ingress API for 1.22

This project generates the list of deprecated Ingresses for 1.22 and Ingress that are not switched to new V1 ingress controllers along with team slack channel details.

## How to run

To run the application locally, you must have the following:

- An environment variable set called `KUBECONFIG` with the value of your kubeconfig path.
- An environment variable set called `AWS_REGION` that contains the valid username of a GitHub user.

You need to run this project from the root directory as this uses the main go module

```
cd ../..
go run cmd/deprecated-ingress/generate-ingresses.go
```
