# Logging with Fluentd to Elasticsearch on Kubernetes

## Introduction
This namespace contains all the resources required for deploying `fluentd` as `DaemonSet` on the cluster, configured to collect the logs of all containers in the clusters, as well as audit logs. The logs are then sent to Elasticsearch.

These files are a customised version of the official Kubernetes `fluentd-es` templates. [Repo link.](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/fluentd-elasticsearch)

### Fluentd

The only configuration required for `fluentd` is setting the Elasticsearch endpoint. In `kube-fluentd-es.yaml`, find the environment variables for the `DaemonSet` and set the Elasticsearch host accordingly:

```yaml
- name:  FLUENT_ELASTICSEARCH_HOST
    value: "search-foo-bar-8kqptsuu1d1sxfwpae813685ng.eu-west-1.es.amazonaws.com"
```

The value can be acquired from the AWS console (since we are using AWS Elasticsearch) or the [terraform state](https://github.com/ministryofjustice/cloud-platform-aws-meta-configuration/tree/master/Kibana/) that creates the Elasticsearch domains.

**IMPORTANT:** Make sure you remove the scheme (`https://`) part of the URL in the `value:` otherwise it will not work. This needs to be the hostname.

### Elasticsearch Curator

The `elasticsearch-curator.yaml` file is made up of two resources, a ConfigMap and a CronJob. The ConfigMap contains a Python script that generates AWS credentials in the `aws-platforms-integration` account and deletes logs older than 1 month in the `cloud-platform-test` elasticsearch cluster.
https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/curator.html

The CronJob is responsible for scheduling the Python script to run every day at 1am.

## Elasticsearch access

Currently the Elasticsearch domain allows access to its endpoint based on IP Whitelisting. If you experience any connection issues, check the access policy for your ES Domain and ensure that the IP addresses for all of the availability zones for your cluster (NAT Gateways) are properly defined in the [policy](https://github.com/ministryofjustice/cloud-platform-aws-meta-configuration/blob/master/Kibana/variables.tf).
