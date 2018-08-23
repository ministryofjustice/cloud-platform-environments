# Kiam - AWS IAM Role Management 

## Overview

**The purpose of this documentation is to serve the needs of all types of users that will interact with Kiam.**

* Firstly, this document will guide anyone seeking to deploy Kiam on a new cluster for the first time.

* Secondly, this document will educate anyone who simply would like to know how Kiam works and why we need it.

* Lastly, the document will enable a user who is seeking to utilise Kiam on a cluster, where it has already been deployed and configured. 

## What is Kiam, why we need it, and how it works.

Traditionally in AWS, resources are allocated in the form of IAM Roles. An example of this would be if you had an instance running an application that needed to access an S3 bucket, you'd give it permission to do so via an IAM Policy within a Role and then you'd allow the instance to assume that Role.

With the implementation of Kubernetes, we have entered into the world of Multi-Tenanted containers. As you will be aware, Nodes are still at their core, EC2 instances. Essentially, this means that the Nodes of a cluster will assume IAM credentials from AWS so the multiple containers in each Node can access the AWS resources they require to function.

The problem with the above paragraph is that the IAM Role stops at the Node level and all the containers below the Nodes share the same credentials and permissions to all the AWS resources that are specified on the Nodes IAM Role. 

An example of where this could become problematic is you may have an application in a cluster that requires full read and write access to a specific S3 Bucket. So to give access to the S3 bucket for the application, you'd have to modify the Node IAM Role to include a policy for full read and write access to S3. Bearing in mind, that all the containers under the Nodes share the same IAM role, you're not just given that singular container access to the S3 bucket, but every container under the Nodes.

This is where Kiam comes in as the solution.

Kiam solves this problem by essentially acting as a proxy between the Nodes and containers and communicates with the EC2 Metadata API. Kiam deploys an Agent Pod on every worker node that is able to intercept all traffic going to the EC2 Metadata API from a container and then assign it temporary credentials to only access the AWS resources that it requires.

Kiam also deploys a Server Pod on every Master Node that takes the requests from the Agent Pods for temporary credentials and then communicates with the AWS STS API to retrieve those temporary credentials, which is then fed back through the Server, Agent and applied to the Pod. 

What the process of Kiam, as described above, is part of what is called **Multi-Tenant Issolation**.

To help demonstrate how Kiam works with a cluster, please see the diagram below: 

![alt text](https://image.ibb.co/gM23OK/kiam.png "Kiam Diagram")


Kiam requires Namespaces and Pod annotations, along with specific IAM Roles and Trust Policies to be created, in order for it to function as intended. The details of this will be covered in the **Post-Installation Usage** section of this documentation.

Hopefully, this overview has provided enough detail to understand what Kiam is, how it works and why we need it. If you'd like to read into Kiam further, visit their official Repo: https://github.com/uswitch/kiam 

## Kiam Installation

This section of the documentation is intended to be used as a guide for someone seeking to deploy Kiam on a MoJ Cloud Platform cluster for the first time.

Helm has been utilised to make the process of installation more simplistic. 

The Helm Chart that you will use to install Kiam on a Cloud Platform cluster is an adapted version of the official [stable/kiam](https://github.com/helm/charts/tree/master/stable/kiam) chart.

As detailed in the **Overview** section above, the Helm chart deploys an Agent Pod on every Worker Node and a Server Pod on every master node. To enable the Agent and Server pods to be able to communicate securely, mutual TSL authentication is required. These certificates have to be generated manually and then encoded into `base64` values. These values then need to be placed into the `server-secret.yaml` and `agent-secret.yaml` files that are found within the `templates` directory of the chart.

### TSL Generation and Placement

**Pre-Reqs:**

* Working installation of Go 1.8+ with a properly set `GOPATH`
  
### Generation

To generate the TSL certificates, we will be using a CLI tool called [CFSSL](https://github.com/helm/charts/tree/master/stable/kiam).

To install CFSSL and it's supporting tools:
```go
$ go get -u github.com/cloudflare/cfssl/cmd/...
```
This will download, build, and install all of the utility programs (including cfssl, cfssljson, and mkbundle among others) into the $GOPATH/bin/ directory.

Move to the directory where the tools have been installed:
```shell
$ cd $GOPATH/bin/
```

Now to generate the certificates, 3 sample JSON files need to used. In the `tls-templates` directory, you will find the following 3 files, `agent.json`, `server.json`, and `ca.json`.

For the sake of simplicity, copy these 3 files and copy them in your `$GOPATH/bin/` directory.

Now you're ready to generate the certificates:

1) Create the Certificate Authority Cert and Key
```
cfssl gencert -initca ca.json | cfssljson -bare ca
```

2) Create Server pair
```
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem server.json | cfssljson -bare server
``` 

3) Create Agent pair
```
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem agent.json | cfssljson -bare agent
``` 

### Placement

The next step is to `base64` encode the generated `.pem` files and place the values into the correct locations with the `server-secret.yaml` and `agent-secret.yaml` files.

In your editor of choice, open both `secret.yaml` files.

You will see a vacant block of code like the below, in both files:
```yaml
data:
  ca: 
  cert: 
  key: 
```

#### Server PEMs

1) Execute the command for the `server.pem` file:
```
base64 server.pem
```

2) Copy and paste the `base64` encoded value into the `cert:` section of the `server-secret.yaml` file, which will look like this:
```yaml
data:
  ca: 
  cert: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1..
  key: 
```   

3) Repeat the same instructions as above, but this time using the `server-key.pem` file and pasting the contents into the `key:` section, which should end up looking like this:
```yaml
data:
  ca: 
  cert: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1..
  key: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1J..
```  

#### Agent PEMs

1) Execute the command for the `agent.pem` file:
```
base64 agent.pem
```

2) Copy and paste the `base64` encoded value into the `cert:` section of the `agent-secret.yaml` file, which will look like this:
```yaml
data:
  ca: 
  cert: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tL..
  key: 
```   

3) Repeat the same instructions as above, but this time using the `agent-key.pem` file and pasting the contents into the `key:` section, which should end up looking like this:
```yaml
data:
  ca: 
  cert: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1..
  key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVk..
```  

#### CA PEM

1) Lastly, execute the command for the `ca.pem` file:
```
base64 ca.pem
```

2) Now you need to copy the encoded value and paste it into the `ca:` section of **both** the `server-secret.yaml` and `agent-secret.yaml` files. Both files should end up looking like this:
```yaml
data:
  ca: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0t..
  cert: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1..
  key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVk..
```  

3) To complete the process, save both the `server-secret.yaml` and `agent-secret.yaml` files, with their new `base64` encode values within.

### Cluster Node IAM Policy

For the Server process to work correctly, the Policy below needs to be added to your current IAM Role for your **Master** nodes.
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "*"
    }
  ]
}
```   

### Helm Install

After successfully completing the steps above, you should now be ready to install Kiam onto your cluster via the Helm chart you've just configured.

Firstly, ensure you are connected to the correct cluster:
```
$ kubectl cluster-info
```

**When the Helm chart is deployed, ALL Pod traffic to the AWS Metadata API will be intercepted by Kiam and any Pod that wishes to assume a role will not be able to until the steps detailed in the Post-Installation Usage are applied.**

**NOTE: The name of the Helm install MUST be `kiam`. Anything else will result in a failed installation.**

Now you can go ahead and install the chart into the `kube-system` namespace with the following command:
```
$ helm install --name kiam helm/kiam-chart --namespace kube-system -f values.yaml
```

Verify Kiam has been installed successfully by checking the status of the Pods, there should be one Agent per Worker Node and one Server per Master Node:
```
$ kubectl get pods -n kube-system
```

## Post-Installation Usage

This section of the documentation will show how Kiam is used to assign IAM Roles to Pods and provide a demo to which you can yourself to ensure your installation of Kiam is working correctly.

### Annotations

Quite simplistically, Kiam uses an **annotation** added to a Pod to express the Role it should assume. We will come back to this point in a moment.

At a higher level than a Pod, we have Namespaces that the Pods sit under. In order for a Pod's annotated Role to be assumed, it is required for the Namespace it sits under to be annotated with a regular expression expressing which roles can be assumed by Pods in the Namespace:
```yaml
kind: Namespace
metadata:
  name: example-namespace
  annotations:
    iam.amazonaws.com/permitted: ".*"
```

Now back to the Pod annotations. As briefly mentioned above, Kiam uses an **annotation** added to a Pod to express the Role it should assume. The value of the annotation key is simply the name of the Role that has been created in AWS's IAM:
```yaml
kind: Pod
metadata:
  name: example-pod
  namespace: example-namespace
  annotations:
    iam.amazonaws.com/role: s3FullAccess
```
### Application Roles

When you have created a Role for a Pod/Application to assume, you must also ensure it has trust relationship policy with Master Node Role.

Once you have created the Role for your application, in the AWS IAM Console, click into the role and select the **Trust relationships** tab.

Then click the **Edit trust relationship** button, and you should see a JSON editor, populated with something very similar to this:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```
Edit the JSON policy similar to the one above that adds an extra block allowing the Role to be assumed by the Master Node Role:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<account-id>:role/<cluster-node-role-name>"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```
Once the policy has been modified to include the ARN of the Master Node Role, click **Update trust policy**, and you should be all set.

### Testing Kiam Works 

If all the steps above in the document have been followed correctly you should now have a fully functioning Kiam setup, which allows Pods to assume roles individually.

A simple way to test this is to deploy an annotated Namespace, like the one exampled above. Then within that Namespace deploy an AWS CLI Pod, which has been annotated with a properly configured Role which grants it permission to read S3 Buckets.

Once the Pod has launched within the Namespace, `kubectl exec` into the pod and simply run `aws s3 ls`. 

If Kiam is working correctly, the command above should return the names of all the S3 Buckets in that AWS account and this is confirmation that Kiam has provided the Pod with a temporary Role.

## Closing Remarks

This is just our first implementation of Kiam, and as time goes on and the Kiam tool is updated, we aim to embrace it's new features and update this document where necessary.

This chart uses Kiam v2.7, but the original and current stable/kiam chart uses v2.8. The chart had to be adapted to mitigate a few lines of code that weren't compatible with v2.7. We intentionally shied away from v2.8, as the developers themselves admitted it was buggy and that people should use v2.7 until a stable v3.0 version is released.

I'd like to thank the creators of Kiam for their work, and their repo can be found here: https://github.com/uswitch/kiam