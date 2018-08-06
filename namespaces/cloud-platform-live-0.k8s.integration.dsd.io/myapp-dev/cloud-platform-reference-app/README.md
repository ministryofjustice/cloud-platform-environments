# Getting started on the MoJ Cloud Platform: Demo Application
This repository will contain the required files to follow along with the MoJ Digital Getting Started ----Add Link----, the intended outcome of this document is to allow you to run a basic Django web application on the MoJ Cloud Platform.

When discussing the MoJ Cloud Platform in this context, we're referring to a Kops deployed Kubernetes cluster hosted on AWS.

Getting started guide: https://ministryofjustice.github.io/cloud-platform-user-docs/cloud-platform/env-create/#creating-a-cloud-platform-environment

The cluster you'll be using for this exercise is the cloud-platform-non-prod cluster.

## Table of contents
   * [Installation with kubectl](#installing-with-kubectl)
   * [Developing and building the app locally](#local-development)
   * [Building, tagging and pushing to ECR](#pushing-to-ecr)
   * [Creating a Cloud Platform Enviroment](#app-deploy)
   * [Deploying with Helm](#helm-deploy)

## Installing with kubectl
There are many ways to deploying applications to the MoJ Cloud Platform, the below will show the simplist; kubectl.

### Prerequisites
* Install kubectl
```brew install kubectl```

* Authenticate
Gain access to the non-production cluster by authenticating with your GitHub account. Use the instructions here:
---- add-link ----

* Create namespace
Follow the instructions here to create a namespace on the cloud-platform-non-prod cluster: https://ministryofjustice.github.io/cloud-platform-user-docs/cloud-platform/env-create/#creating-a-cloud-platform-environment

### TL;DR
```
# Clone repo
$ git clone git@github.com:ministryofjustice/cloud-platform-reference-app.git
$ cd cloud-platform-reference-app

# Apply Manifests
$ kubectl apply --namespace=<namespace> -f kubectl_deploy/.

# Ensure app is running
$ kubectl get pods -n <namespace>

# Grab URL and test in browser of your choice
$ kubectl get ingress -n <namespace>

# Delete app when done
$ kubectl delete --namespace=<namespace> -f kubectl_deploy/.
$ kubectl get pods -n <namespace> # you should have nothing running
```
## Local development
### Prerequisites
* python >= 3.6

* pip

* virtualenv (optional)

### Installation

#### Creating the environment

Create a virtual python environment for the project. If you're not using virtualenv or virtualenvwrapper you may skip this step.

#### For virtualenvwrapper
```mkvirtualenv {{ project_name }}-env```

#### Clone the code
```git clone git@github.com:ministryofjustice/cloud-platform-reference-app.git {{ project_name }}```

#### Install requirements

This step also creates githooks which will run all the necessary tests before allowing to commit.

```make prepare```

If installation of githooks isn't necessary you can run

```pip install -r requirements.txt```

#### Running

```python django_reference_app/manage.py runserver```

Open browser to [http://127.0.0.1:8000](http://127.0.0.1:8000)
#### Running tests

```make test```

## Pushing to ECR
### Prerequisites
* Docker

* AWS CLI

The decision was made to use the Amazon Elastic Container Registry. ECR is a fully-managed [Docker](https://aws.amazon.com/docker/) container registry that makes it easy for developers to store, manage, and deploy Docker container images.

A repository has been created on the AWS account *'mojds-platform-integrations'* called *'arn:aws:ecr:eu-west-1:926803513772:repository/cloud-platform-demo-app'*.

### Building, tagging and pushing to ECR
1) Retrieve the `docker login` command that you can use to authenticate your Docker client to your registry:

```aws ecr get-login --no-include-email --region eu-west-1```

2) Run the `docker login` command that was returned in the previous step.

3) Build your Docker image using the following command.

```docker build -t cloud-platform-demo-app .```

4) After the build completes, tag your image so you can push the image to this repository:

```docker tag cloud-platform-demo-app:latest 926803513772.dkr.ecr.eu-west-1.amazonaws.com/cloud-platform-demo-app:latest```

5) Run the following command to push this image to your newly created AWS repository:

```docker push 926803513772.dkr.ecr.eu-west-1.amazonaws.com/cloud-platform-demo-app:latest```

### CircleCI build/push/deploy

Following every commit to the master branch a job kicks off, which builds the Dockerfile on root, tags/pushes to ECR and deploys the reference application on the Cloud Platform cluster known as 'non-production'.

The configuration for this job is in the directory `.circleci/config`. 

To view the application live following deployment, you can view it here:

https://circleci-demo.apps.non-production.k8s.integration.dsd.io

## To do;
 - [ ] Add postgres manifest
 - [ ] Add Helm Chart for Django app + postgres
 - [ ] Document postgres deployment and helm chart addition
