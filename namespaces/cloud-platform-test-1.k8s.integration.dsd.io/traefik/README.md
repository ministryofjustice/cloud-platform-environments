# Traefik ingress controller

## Introduction
Traefik is a very powerful ingress controller that is easy to implement and manage.
One of it's highlight features is that it offers a dashboard that visualises your hosts and offers health checks.

This guide will serve the purpose of installing Traefik on a cluster and also how to provision ingress objects that run through Treafik.

## Installation
This guide will use Helm to install Traefik.

In this directory, you will see the `values.yaml` file that has the following contents:
```yaml
dashboard:
    enabled: true
    domain: #ADD DESIRED DOMAIN
rbac:
    enabled: true
```

### Route 53 Config

The first task you need to complete is to set up a DNS record for the part of the URL which will tail the full host URL once Traefik has been installed successfully.

Start by logging into AWS and navigating to the Route 53 dashboard.

This example will use `*.test-1-traefik.k8s.integration.dsd.io` as the wildcard URL.

Click `Create Hosted Zone` and in the `Domain Name` field, input `test-1-traefik.k8s.integration.dsd.io` and click `Create`. Copy the Name Server values that are generated.

As `k8s.integration.dsd.io` is already a Hosted Zone, we need to go into it and delegate `test-1-traefik.k8s.integration.dsd.io` by adding it as a Record Set.

Inside the `k8s.integration.dsd.io` Hosted Zone, click `Create Record Set` and switch the type to `NS - Name server`. Now append the Name with `test-1-traefik`. Lastly, past the Name Server values into the Value field and click `Create`.

### Helm Deploy

Start by amending the `values.yaml` file by adding a suitable domain for the dashboard, like the following:
```yaml
dashboard:
    enabled: true
    domain: dashboard.test-1-traefik.k8s.integration.dsd.io
rbac:
    enabled: true
```

Deploy Traefik using the following command:
```
helm install stable/traefik --name traefik -f values.yaml --namespace kube-system
```
Wait a few moments and then run the following command:
```
kubectl describe svc traefik --namespace kube-system | grep Ingress | awk '{print $3}'
```
You should have been provided with a load balancer URL. Copy it.

Navigate back to Route 53 and click into the `test-1-traefik.k8s.integration.dsd.io` Hosted Zone.

Click `Create Record Set` and simply append the Name with `*`. Keep the Type as `A - IPv4 address` and toggle Alias to `Yes`. Finally, for the Alias Target field, paste the load balancer URL and click `Save Record Set`.

Wait a few minutes and you should now be able to access the Traefik dashboard by following `dashboard.test-1-traefik.k8s.integration.dsd.io`.

## Configuring an App to use the Traefik Ingress Controller

Traefik knows to handle the ingress for an application simply through the use of the annotation in the ingress manifest file under `metadata`.

The annotation is:
`kubernetes.io/ingress.class: "traefik"`

An example of an Ingress manifest file that uses Traefik as it's controller should look similar to the following:
```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    kubernetes.io/ingress.class: "traefik"
spec:
  rules:
  - host: example.test-1-traefik.k8s.integration.dsd.io
    http:
      paths:
      - path: /
        backend:
          serviceName: example-service
          servicePort: 8000
```


