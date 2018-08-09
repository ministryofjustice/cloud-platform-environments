# Resource Quota

Each namespace can be assigned resource quota. By default, a pod will run with unbounded CPU and memory requests/limits. Specifying quota allows to restrict how much of cluster resources can be consumed across all pods in a namespace. 


#### Step 1: Create a namespace

This example will work in a custom namespace to demonstrate the concepts involved.

Let's create a new namespace called limit-env:

```console
$ kubectl create -f namespace.yaml
namespace "limit-env" created
$ kubectl get namespaces
NAME            LABELS    STATUS    AGE
default         <none>    Active    2m
limit-env       <none>    Active    39s
```

Step 2: Apply a quota to the namespace
-----------------------------------------

Users may want to restrict how much of the cluster resources a given namespace may consume
across all of its pods in order to manage cluster usage.  To do this, a user applies a quota to
a namespace.  A quota lets the user set hard limits on the total amount of node resources (cpu, memory)
and API resources (pods, services, etc.) that a namespace may consume. In term of resources, Kubernetes
checks the total resource *requests* and *limits* of all containers/pods in the namespace.

Let's create a simple quota in our namespace:

```console
$ kubectl create -f 03-resourcequota.yaml --namespace=limit-env
resourcequota "namespace-quota" created
```

Once your quota is applied to a namespace, the system will restrict any creation of content
in the namespace until the quota usage has been calculated.

You can describe your current quota usage to see what resources are being consumed in your
namespace.

```console
$ kubectl describe resourcequota -n limit-env
Name:            compute-resources
Namespace:       limit-env
Resource         Used   Hard
--------         ----   ----
limits.cpu       ---    2000m
limits.memory    ---    2Gi
requests.cpu     ---    100m
requests.memory  ---    128Mi
```

Step 3: Applying default resource requests and limits
-----------------------------------------
Pod authors rarely specify resource requests and limits for their pods.

Since we set a limitrange as part of namespace creation, everytime a pod is created in this namespace, if it has not specified any resource request/limit, the default
amount of cpu and memory per container will be applied, and the request will be used as part of admission control.

Lets create a pod without any resoruces specified:

```console
$ kubectl create -f pod.yaml --namespace=limit-env
NAME          READY     STATUS    RESTARTS   AGE
pod1          1/1       Running   0          1m
```

And if we print out our quota usage in the namespace we will see the used column now has values:

```console
$ kubectl describe resourcequota -n limit-env
Name:            compute-resources
Namespace:       limit-env
Resource         Used   Hard
--------         ----   ----
limits.cpu       1000m  2000m
limits.memory    1Gi    2Gi
requests.cpu     100m   100m
requests.memory  128Mi  128Mi
```

You can now see the pod that was created is consuming explicit amounts of resources (The default vales in the limitrange),
and the usage is being tracked by the Kubernetes system properly.

If you try create pods that cumulativly go over the quota, you will get the following message:

```console
kubectl create -f pod2.yaml -n limit-env
Error from server (Forbidden): error when creating "pod2.yaml": pods "pod2" is forbidden: exceeded quota: compute-resources, requested: requests.cpu=400m,requests.memory=100Mi, used: requests.cpu=2000m,requests.memory=200Mi
```


Summary
----------------------------
Actions that consume node resources for cpu and memory can be subject to hard quota limits defined
by the namespace quota. The resource consumption is measured by resource *request* and *limits* in pod specification.

Any action that consumes those resources can be tweaked, or can pick up limitrange defaults to
meet your end goal.

For more inforamtion, see the offical Kubernetes documentation for:

[Configure Default CPU Requests and Limits for a Namespace](https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/cpu-default-namespace/)