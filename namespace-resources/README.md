# Overview

This directory stores template Kubernetes manifest files that can be used to create a namespace and resources for that chosen namespace.

These files define key elements of the namespace and restrictions we want to place on it so that we have security and resource allocation properties. We describe each of these files in more detail below.

### 00-Namespace.yaml 
This file defines your namespace.

###0 01-rbac.yaml 
We will also create a RoleBinding resource by adding the 01-rbac.yaml file. This will provide us with access policies on the namespace we have created in the cluster.

A role binding resource grants the permissions defined in a role to a user or set of users. A role can be another resource we can create but in this instance we will reference a Kubernetes default role ClusterRole - admin.

This RoleBinding resource references the ClusterRole - admin to provide admin permissions on the namespace to the set of users defined under subjects. In this case, the <yourTeam> GitHub group will have admin access to any resources within the namespace myapp-dev.

### 02-limitrange.yaml

As we are working on a shared Kubernetes cluster it is useful to put in place limits on the resources that each namespace, pod and container can use. This helps to stop us accidentally entering a situation where a one service impacts the performance of another through using more resources than are available.

### 03-resourcequota.yaml

The ResourceQuota object allows us to set a total limit on the resources used in a namespace

### 04-networkpolicy

The NetworkPolicy object defines how groups of pods are allowed to communicate with each other and other network endpoints. By default pods are non-isolated, they accept traffic from any source. We apply a network policy to restrict where traffic can come from, allowing traffic only from the ingress controller and other pods in your namespace.


## Usage

We use terraform to automate the creation of these files and the directory for your namespace that stores them.

```hcl
    terraform init
    terraform plan
    terraform apply
    # if you want to specify another cluster, use terraform apply -var "cluster=cloud-platform-test-1"

```
Once you fill your values, you can find your kubernetes file in cloud-platform-environments/$cluster/$your-namespace/

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