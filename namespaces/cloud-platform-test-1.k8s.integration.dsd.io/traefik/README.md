# Traefik ingress controller

## Introduction
Traefik is a very powerful ingress controller that is easy to implement and manage.
One of it's highlight features is that it offers a dashboard that visualises your hosts and offers health checks.

This guide will serve the purpose of installing Traefik on a cluster and also how to provision ingress objects that run through Treafik.

## Installation
This guide will use a collection of manifest files to install Traefik.

In this directory, you will see three manifest files, `traefik-deployment.yaml`, `traefik-rbac.yaml`, and `traefik-ui.yaml`.

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


