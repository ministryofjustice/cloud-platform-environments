# Django Reference Helm Chart
## Introduction
This directory contains the necessary files required to install the MoJ Django Reference application via the Helm package manager. This application is intended to be used to demonstrate the ease of deployment on a MoJ Cloud Platform. 

Please follow along with the [tutorial](https://ministryofjustice.github.io/cloud-platform-user-docs/cloud-platform/app-deploy-helm/#tutorial-deploying-an-application-to-the-cloud-platform-with-helm) and feel free to drop the Cloud Platform team a line if you have any feedback at our Slack channel #ask-cloud-platforms. 

## Installing the Chart
To install the chart:
```
helm install helm_deploy/django-app/. \
  --name <app-name> \
  --namespace <env-name> \
  --set deploy.host=<URL>
```
The ```app-name``` will be the name of your deployment. For example our reference Django reference app would be: `django-application`.

The ```env-name``` here is the environment name (namespace) you've created in the [Creating a Cloud Platform Environment](https://ministryofjustice.github.io/cloud-platform-user-docs/cloud-platform/env-create/#creating-a-cloud-platform-environment) guide.

The ```URL``` argument is the address your application will be served. An example of this is: `django-app.apps.cloud-platforms-test.k8s.integration.dsd.io`.

There are a number of install switches available. Please visit the [Helm docs](https://docs.helm.sh/helm/#helm-install) for more information. 

## Deleting the Chart
To delete the installation from your cluster:
```
helm del --purge <app-name>
```
## Configuration
| Parameter  | Description     | Default |
| ---------- | --------------- | ------- |
| `replicaCount` | Used to set the number of replica pods used. | `1` |
| `image.repository` | The image repository location. | `926803513772.dkr.ecr.eu-west-1.amazonaws.com/cloud-platform-demo-app`|
| `image.tag` | The image tag. | `latest` |
| `image.pullPolicy` | Whether the image should pull | `Always` |
| `service.type` | The type of service you wish to use | `ClusterIP` |
| `service.port` | The port your service will use | `"8000"` |
| `deploy.host` | The URL of your application | `""` |
| `postgresql.postgresUser` | Postgres user | `""` |
| `postgresql.postgresPassword` | Postgres password | `""` |
| `postgresql.postgresDatabase` | Name of postgres Database | `django_reference` |
| `postgresql.postgresHost` | Postgres host | `""` |

## Chart Structure
### Chart.yaml
The YAML for our chart. This contains our API version, chart description, name and version. 

### requirements.yaml
A YAML file listing dependencies for the chart.

### values.yaml
The default configuration values for this chart.

### charts/
A directory containing any charts upon which this chart depends.

### templates/ 
A directory of templates that, when combined with values, will generate valid Kubernetes manifest files.

### templates/NOTES.txt
A plain text file containing short usage notes.

 
## Secrets
This repository takes advantage of the Kubernetes secrets manager. The secrets here are deliberately stored in plain text. If you're using this repository as a reference for a production or non-production application. These files **must** be encrypted. 

For more information on how to create secrets on the MoJ Cloud Platform, please read our [Adding Secrets](https://ministryofjustice.github.io/cloud-platform-user-docs/cloud-platform/add-secrets-to-deployment/#adding-a-secret-to-an-application) document.

## Architecture Decisions
The Django Reference application in this repository doesn't follow best practice. In particular, we're utilising an on-cluster database. In production you would take advantage of a managed service, like RDS. 
