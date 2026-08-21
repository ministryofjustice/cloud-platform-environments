resource "kubernetes_deployment" "opensearch_test_proxy" {
  metadata {
    name      = "opensearch-test-proxy"
    namespace = var.namespace
    labels = {
      app       = "opensearch-test-proxy"
      namespace = var.namespace
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app       = "opensearch-test-proxy"
        namespace = var.namespace
      }
    }
    template {
      metadata {
        labels = {
          app       = "opensearch-test-proxy"
          namespace = var.namespace
        }
      }
      spec {
        service_account_name = module.opensearch.service_account_name
        container {
          name  = "opensearch-test-proxy"
          image = "public.ecr.aws/aws-observability/aws-sigv4-proxy:1.10"
          args  = ["--log-failed-requests", "--name", "es", "--region", data.aws_region.current.name, "--host", module.opensearch.endpoint]
          security_context {
            allow_privilege_escalation = false
            run_as_non_root            = true
            run_as_user                = 10001
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "opensearch_test_proxy" {
  metadata {
    name      = "opensearch-test-proxy"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "opensearch-test-proxy"
    }
    port {
      port        = 8080
      target_port = 8080
    }
  }
}
