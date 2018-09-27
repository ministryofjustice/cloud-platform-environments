# Pod Security Policy

A Pod Security Policy (PSP) is a cluster-level resource that controls security sensitive aspects of the pod specification. The PodSecurityPolicy objects define a set of conditions that a pod must run with in order to be accepted into the system, as well as defaults for the related fields. 

The Kubernetes documentation on Pod Security Policies is really well defined. If you'd like to find out how PSP's work please read [here](https://kubernetes.io/docs/concepts/policy/pod-security-policy/).

The intention of this document is to provide you with instructions to apply a `Restricted` and `Privileged` Pod Security Policy to a Cloud Platform cluster. 

## tl;dr

```bash
# enable the podsecuritypolicy Admission Controller via kops.

# clone this repo.

git clone git@github.com:ministryofjustice/cloud-platform-environments.git

kubectl create -f ./namespaces/cloud-platform-test-1.k8s.integration.dsd.io/pod-security-policy.yaml

# test... it should return 'yes'. 

kubectl --as system:serviceaccount:logging:default auth can-i use podsecuritypolicy/privileged
```

## Step one: Enable Admission Controller
The Pod Security Policy requires an [Admission Controller](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/) to ensure pods have relevant permission. An admission controller is a piece of code that intercepts requests to the Kubernetes API server prior to persistence of the object, but after the request is authenticated and authorized.

To enable the admission controller in a Cloud Platform cluster you must use Kops, which utilizes the server flag `enable-admission-plugins`.

Simply ensure the following code exists in your Kops manifest file:
```yaml
enableAdmissionPlugins:
- PodSecurityPolicy
```
To see this in a working environment, please see the [test-1 cluster](https://github.com/ministryofjustice/kubernetes-investigations/blob/master/kops/cloud-platform-test-1.yaml) manifest.

Once complete, please run a Kops update to apply your amended manifest file. 

## Step two: Create your Pod Security Policy
Using the [cloud-platform-environments](https://github.com/ministryofjustice/cloud-platform-environments/tree/master/namespaces/cloud-platform-test-1.k8s.integration.dsd.io) repository, copy the `pod-security-policy.yaml` to the root of your cluster directory, as shown on the [test-1 cluster](https://github.com/ministryofjustice/cloud-platform-environments/tree/master/namespaces/cloud-platform-test-1.k8s.integration.dsd.io/) and merge to master. A [concourse](https://github.com/ministryofjustice/cloud-platform-concourse/tree/master/pipelines) pipeline will complete every 15 minutes and apply the Pod Security Policy to your desired cluster.

The `pod-security-policy.yaml` consists of a:
#### Privileged Policy
This is the least restricted policy you can create, equivalent to not using the pod security policy admission controller.
#### Restricted Policy
This a restrictive policy that requires users to run as an unprivileged user, blocks possible escalations to root, and requires use of several security mechanisms.
#### ClusterRole and ClusterRoleBinding
A Cluster Role and Rolebinding is created to authorise service accounts to access the Pod Security Policy. 

All authenticated users will be able to use the `Restricted` Pod Security Policy, but only a few service accounts will be able to use the `Privileged`.  

## Step three: Test a service account can access the Privileged psp

Now the Admission Controller's running and the Pod Security Policies have been applied to your cluster you need to ensure a service account in a relevant namespace has permission to access the `Privileged` psp. 

Run:
```bash
kubectl --as system:serviceaccount:logging:default auth can-i use podsecuritypolicy/privileged
```

## How do I ensure my pods are using the Privileged policy

The `Privileged` policy is to be used only when necessary. To ensure your service account can use the Privileged policy simply apply your service account to the `pod-security-policy.yaml` and apply on the cluster.  