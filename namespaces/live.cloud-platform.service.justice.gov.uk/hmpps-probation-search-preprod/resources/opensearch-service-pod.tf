resource "kubernetes_pod" "opensearch_test_proxy" {
  metadata {
    name      = "opensearch-test-proxy"
    namespace = var.namespace
    labels = {
      app = "opensearch-test-proxy"
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
    restart_policy = "Always"
  }
}