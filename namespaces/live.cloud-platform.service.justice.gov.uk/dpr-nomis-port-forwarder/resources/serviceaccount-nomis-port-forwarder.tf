module "serviceaccount_nomis-port-forwarder" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "01-01-2000"

  serviceaccount_name = "nomis-port-forwarder-migrated"
  role_name           = "nomis-port-forwarder-migrated"
  rolebinding_name    = "nomis-port-forwarder-migrated"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  # github_repositories = ["my-repo"]
}

