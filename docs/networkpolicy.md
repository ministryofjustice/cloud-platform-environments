# Network Policy

Network policies are applied to namespaces. By default, if no policies exist in a namespace, then all ingress and egress traffic is allowed to and from pods in that namespace. 

Another way to explain network policies are firewall rules that allow or deny tarffic between pods, these are declarativly configrable in a manifiest (yaml) file. 

Network Policies are applied in near real-time. If you have open connections between pods, applying a Network Policy that would prevent that connection will cause the connections to be terminated immediately. This near real-time gain comes with a small performance penalty on the networking

The current default 04-networkpolicy.yaml prohibits all network traffic from other namespaces except from the namespace with the label - component: ingress-controllers

```yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: allow-ingress-controllers
spec:
  podSelector: {} 
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          component: ingress-controllers
```

Link to [Offical Network Policies documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/)