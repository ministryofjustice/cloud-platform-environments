# kube-prometheus

To install,

```
helm upgrade \
  kube-prometheus \
  --namespace monitoring \
  coreos/kube-prometheus \
  -f helm/kube-prometheus/values.yaml \
  --set-string grafana.adminUser=$(head -c 16 /dev/urandom | xxd -p) \
  --set-string grafana.adminPassword=$(head -c 16 /dev/urandom | xxd -p)
```

The two `--set-string` flags override the admin username and password for grafana, to increase the randomness.
