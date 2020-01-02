# Limit Range

By default, pods inherit CPU and memory limits from the `limitrange` defined
for the namespace in which they are created. However, users can set limits in
their deployments, if pods have specific requirements.

For example:

1. Each node in the cluster has a fixed amount of memory (say, 2GB). The
   cluster operator does not want to accept pods that require more than 2GB of
memory since no node in the cluster can support the requirement. To prevent a
pod from being permanently unscheduled to a node, the operator instead chooses
to reject pods that exceed 2GB of memory as part of admission control.

2. Users may create a pod which consumes resources just below the capacity of a
   machine. The left over space may be too small to be useful, but big enough
for the waste to be costly over the entire cluster. As a result, the cluster
operator may want to set limits that a pod may only consume at most 20% of the
memory and cpu of their average node size in order to provide for more uniform
scheduling and to limit waste.

#### Step 0: Prerequisites
This example requires a running Kubernetes cluster.

#### Step 1: Create a namespace

Let's create a new namespace called limit-env:

```console
$ kubectl create -f 00-namespace.yaml
namespace "limit-env" created
$ kubectl get namespaces
NAME            LABELS    STATUS    AGE
default         <none>    Active    5m
limit-env       <none>    Active    53s
```

#### Step 2: Apply a limit to the namespace

Let's create a simple limit in our namespace.

```console
$ kubectl create -f 02-limitrange.yaml --namespace=limit-env
limitrange "limitrange" created
```

Let's describe the limits that we have imposed in our namespace.

```console
$ kubectl describe limitrange --namespace=limit-env
Name:   limitrange
Namespace:  limit-env
Type        Resource      Min      Max      Default Request      Default Limit      Max Limit/Request Ratio
----        --------      ---      ---      ---------------      -------------      -----------------------
Container   cpu           ---      ---      100m                 1000m               -
Container   memory        ---      ---      128Mi                2000Mi              -
```

In this scenario, we have said the following:

If a container has not specificed CPU and Memory requirements, it will be
assigned the request value of 100m CPU and 128Mi for Memory. **These resources
will be set aside for the container, regardless of how much CPU and memory it
is actually using.**

The limit values of 1000m CPU and 2000Mi Memory are the
maximum amount of resources the container will be allowed to consume before it
is flagged for eviction from the node. In the case of memory, containers which
exceed their limit will be "Out Of Memory Killed (OOMKilled)." For CPU,
containers will be throttled to their limit value.

NB: Although the limit values should only apply at **runtime**, they **do**
affect the scheduling of pods if the namespace has CPU and memory limits
defined by a [Resource Quota]. The sum total of the limit values for all
containers in a namespace may not exceed the limit value set in the namespace's
resource quota. This applies both to CPU and to memory. Because of this, it is
worth being cautious about setting namespace limits via resource quotas, or
users may find themselves unable to create pods, even if the cluster has plenty
of spare capacity, becuase the cluster will not launch containers which
**might** use too many resources if all the pods in a namespace were to spike
at the same time.

At the time of writing, we do not set such namespace memory/CPU limits on the
cloud platform, and instead restrict the number of pods a namespace is allowed
to contain.

#### Step 3: Enforcing limits at point of creation

The limits enumerated in a namespace are only enforced when a pod is created or updated in
the cluster.  If you change the limits to a different value range, it does not affect pods that
were previously created in a namespace.

If a resource (cpu or memory) is being restricted by a limit, the user will get an error at time
of creation explaining why. (This does not currently apply to us as we do not set min/max limits to containers)


#### Step 4: Cleanup

To remove the resources used by this example, you can just delete the limit-env namespace.

```console
$ kubectl delete namespace limit-env
namespace "limit-env" deleted
$ kubectl get namespaces
NAME      LABELS    STATUS    AGE
default   <none>    Active    20m
```

Summary
----------------------------

Cluster operators that want to restrict the amount of resources a single container or pod may consume
are able to define allowable ranges per Kubernetes namespace.  In the absence of any explicit assignments,
the Kubernetes system is able to apply default resource *limits* and *requests* if desired in order to
constrain the amount of resource a pod consumes on a node.

Namespace limitranges and resource quotas are somewhat counter-intuitive, and
we use a simple restriction on the number of pods a namespace can contain, in
order to reduce the risk of a namespace consuming excessive cluster resources.

For more information, see the offical Kubernetes documentation for:

[Configure Default Memory Requests and Limits for a Namespace](https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/memory-default-namespace/)

[Configure Default CPU Requests and Limits for a Namespace](https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/cpu-default-namespace/)


[Resource Quota]: https://kubernetes.io/docs/concepts/policy/resource-quotas/

