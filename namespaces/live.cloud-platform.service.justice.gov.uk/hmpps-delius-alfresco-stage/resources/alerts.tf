locals {
  # Deployment alerts
  # Edit the deployment_alerts map to add or remove deployment alerts
  deployment_alerts = {
    "alfresco-content-services-alfresco-cs-repository" = {
      pod_short_name             = "repository"
      time                       = "5m"
      cpu_threshold              = 0.75
      mem_threshold              = 0.75
      deployment_count_threshold = 5
    }
    "alfresco-content-services-alfresco-cs-tika" = {
      pod_short_name             = "tika"
      time                       = "5m"
      cpu_threshold              = 0.75
      mem_threshold              = 0.75
      deployment_count_threshold = 2
    }
    "alfresco-content-services-alfresco-router" = {
      pod_short_name             = "router"
      time                       = "5m"
      cpu_threshold              = 0.75
      mem_threshold              = 0.75
      deployment_count_threshold = 5
    }
    "alfresco-content-services-alfresco-filestore" = {
      pod_short_name             = "filestore"
      time                       = "5m"
      cpu_threshold              = 0.75
      mem_threshold              = 0.75
      deployment_count_threshold = 1
    }
  }

  # This is used to generate the deployment alerts from the deployment_alerts map
  rendered_deployment_alerts = {
    for pod, alert in local.deployment_alerts : pod => {
      cpu_alert = {
        alert = "${alert.pod_short_name}DeploymentOver${alert.cpu_threshold * 100}PctCpuUsage"
        expr  = "sum(rate(container_cpu_usage_seconds_total{namespace=\"${var.namespace}\", pod=~\"${pod}.*\"}[${alert.time}])) / sum(cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits{namespace=\"${var.namespace}\", pod=~\"${pod}.*\"}) > ${alert.cpu_threshold}"
        for   = alert.time
        labels = {
          severity = var.namespace
        }
        annotations = {
          message       = "${alert.pod_short_name} Deployment CPU usage is over ${alert.cpu_threshold * 100}%"
          runbook_url   = try(alert.runbook_url, null)
          dashboard_url = try(alert.dashboard_url, null)
        }
      }
      mem_alert = {
        alert = "${alert.pod_short_name}DeploymentOver${alert.mem_threshold * 100}PctMemUsage"
        expr  = "sum(rate(container_memory_working_set_bytes{namespace=\"${var.namespace}\", pod=~\"${pod}.*\"}[${alert.time}])) / sum(cluster:namespace:pod_mem:active:kube_pod_container_resource_limits{namespace=\"${var.namespace}\", pod=~\"${pod}.*\"}) > ${alert.mem_threshold}"
        for   = alert.time
        labels = {
          severity = var.namespace
        }
        annotations = {
          message       = "${alert.pod_short_name} Deployment Memory usage is over ${alert.mem_threshold * 100}%"
          runbook_url   = try(alert.runbook_url, null)
          dashboard_url = try(alert.dashboard_url, null)
        }
      }
      pod_available_count = {
        alert = "${split("-", pod)[length(split("-", pod)) - 1]}DeploymentAvailableReplicasLessThan${alert.deployment_count_threshold}"
        expr  = "kube_deployment_status_replicas_available{namespace=\"${var.namespace}\", deployment=~\"${pod}\"} < ${alert.deployment_count_threshold}"
        for   = alert.time
        labels = {
          severity = var.namespace
        }
        annotations = {
          message       = "${alert.pod_short_name} Deployment available replicas is less than ${alert.deployment_count_threshold}"
          runbook_url   = try(alert.runbook_url, null)
          dashboard_url = try(alert.dashboard_url, null)
        }
      }
    }
  }

  rendered_deployment_alerts_list = flatten([
    for pod, alert in local.rendered_deployment_alerts : [
      alert.cpu_alert,
      alert.mem_alert,
      alert.pod_available_count
    ]
  ])

}

resource "kubernetes_manifest" "prometheus_rule_alfresco" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      namespace = var.namespace
      labels = {
        role = "alert-rules"
      }
      name = "prometheus-custom-rules-alfresco"
    }
    spec = {
      groups = [
        {
          name = "application-rules"
          rules = [
            local.rendered_deployment_alerts_list,
            {
              alert = "RDSLowStorage"
              expr  = "aws_rds_free_storage_space_average{dbinstance_identifier=\"${module.rds_alfresco.db_identifier}\"} offset 10m < 10000000000"
              for   = "5m"
              labels = {
                severity = var.namespace
              }
              annotations = {
                message = "[{{ environment|upper }}] RDS free storage space is less than 10GB"
              }
            },
            {
              alert = "RDSHighCPUUtilization"
              expr  = "aws_rds_cpuutilization_average{dbinstance_identifier=\"${module.rds_alfresco.db_identifier}\"} > 75"
              for   = "5m"
              labels = {
                severity = var.namespace
              }
              annotations = {
                message = "[{{ environment|upper }}] RDS CPU Utilization is over 75% for more than 5 minutes"
              }
            },
            {
              alert = "RDSHighMemoryUtilization"
              expr  = "aws_rds_freeable_memory_average{dbinstance_identifier=\"${module.rds_alfresco.db_identifier}\"} < 5000000000"
              for   = "5m"
              labels = {
                severity = var.namespace
              }
              annotations = {
                message = "[{{ environment|upper }}] RDS freeable memory is less than 5GB for more than 5 minutes"
              }
            },
            {
              alert = "RDSHighConnections"
              expr  = "aws_rds_database_connections_average{dbinstance_identifier=\"${module.rds_alfresco.db_identifier}\"} > 100"
              for   = "5m"
              labels = {
                severity = var.namespace
              }
              annotations = {
                message = "[{{ environment|upper }}] RDS database connections are over 100 for more than 5 minutes"
              }
            },
            {
              alert = "RDSHighReadLatency"
              expr  = "aws_rds_read_latency_average{dbinstance_identifier=\"${module.rds_alfresco.db_identifier}\"} > 0.05"
              for   = "5m"
              labels = {
                severity = var.namespace
              }
              annotations = {
                message = "[{{ environment|upper }}] RDS read latency is over 0.1s for more than 5 minutes"
              }
            },
            {
              alert = "IngressLongRequestTime95thPercentile"
              expr  = "histogram_quantile(0.95, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket{namespace=\"${var.namespace}\", ingress=\"alfresco-content-services-alfresco-cs-repository\"}[5m])) by (le)) > 0.75"
              for   = "5m"
              labels = {
                severity = var.namespace
              }
              annotations = {
                message = "[{{ environment|upper }}] 95th percentile of request duration for Ingress is over 0.5s for more than 5 minutes"
              }
            },
            {
              alert = "IngressLongResponseTime95thPercentile"
              expr  = "histogram_quantile(0.95, sum(rate(nginx_ingress_controller_response_duration_seconds_bucket{exported_namespace=\"${var.namespace}\", ingress=\"alfresco-content-services-alfresco-cs-repository\"}[5m])) by (le)) > 0.75"
              for   = "5m"
              labels = {
                severity = var.namespace
              }
              annotations = {
                message = "[{{ environment|upper }}] 95th percentile of response duration for Ingress is over 0.5s for more than 5 minutes"
              }
            },
            {
              alert = "IngressHighErrorRate"
              expr  = "sum(rate(nginx_ingress_controller_requests{exported_namespace=\"${var.namespace}\", ingress=\"alfresco-content-services-alfresco-cs-repository\",status=~\"5.*\"}[5m])) / sum(rate(nginx_ingress_controller_requests{exported_namespace=\"${var.namespace}\", ingress=\"alfresco-content-services-alfresco-cs-repository\"}[5m])) > 0.01"
              for   = "5m"
              labels = {
                severity = var.namespace
              }
              annotations = {
                message = "[{{ environment|upper }}] Error rate for Ingress is over 1% for more than 5 minutes"
              }
            }
          ]
        }
      ]
    }
  }
}
