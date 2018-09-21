# Overview

This directory stores template Kubernetes manifest files that can be used to create a namespace and resources for that chosen namespace.

These files define key elements of the namespace and restrictions we want to place on it so that we have security and resource allocation properties. We describe each of these files in more detail below.

### 00-Namespace.yaml 
In Kubernetes you run your application in a namespace; namespaces allow us to subdivide our cluster for multitenacy and provide isolation of Kubernetes resources..

### 01-rbac.yaml 

Role base access control will provide permission to grant access to resources within your namespace. You will need to provide your github team that matches the Github API as your github team will be given access to your namespace via this file.

### 02-limitrange.yaml

As we are working on a shared Kubernetes cluster it is useful to put in place limits on the resources that each namespace, pod and container can use. This helps to stop us accidentally entering a situation where a one service impacts the performance of another through using more resources than are available.

### 03-resourcequota.yaml

The ResourceQuota object allows us to set a total limit on the resources used in a namespace

### 04-networkpolicy

The NetworkPolicy object defines how groups of pods are allowed to communicate with each other and other network endpoints. By default pods are non-isolated, they accept traffic from any source. We apply a network policy to restrict where traffic can come from, allowing traffic only from the ingress controller and other pods in your namespace.

### Prereq

To automate the creation of the namespace-resources files, you will need terraform installed locally

```
brew install terraform

```


## Usage

We use terraform to automate the creation of these files and the directory for your namespace that stores them.

```hcl
    terraform init
    terraform plan
    terraform apply
    # if you want to specify another cluster, use terraform apply -var "cluster=cloud-platform-test-1"

```
Once you fill your values, you can find your kubernetes file in cloud-platform-environments/$cluster/$your-namespace/ directory.

You can then check these files into github so that our pipeline can apply these flies into your chosen cluster.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| application |  | string | - | yes |
| business-unit | Area of the MOJ responsible for the service | string | - | yes |
| cluster | What cluster are you deploying your namespace. I.E cloud-platform-test-1 | string | `cloud-platform-live-0` | no |
| contact_email | Contact email address for owner of the application | string | - | yes |
| environment |  | string | - | yes |
| github_team | This is your team name as defined by the GITHUB api. This has to match the team name on the Github API | string | - | yes |
| is-production |  | string | `false` | no |
| namespace | Namespace you would like to create on cluster <application>-<environment>. I.E myapp-dev | string | - | yes |
| owner | Who is the owner/Who is responsible for this application | string | - | yes |
| source_code_url | Url of the source code for your application | string | - | yes |