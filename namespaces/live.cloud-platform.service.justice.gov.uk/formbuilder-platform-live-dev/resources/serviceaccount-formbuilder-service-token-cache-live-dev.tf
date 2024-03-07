module "serviceaccount_formbuilder-service-token-cache-live-dev" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "07-03-2024"

  serviceaccount_name = "formbuilder-service-token-cache-live-dev"
  role_name = "formbuilder-service-token-cache-live-dev"
  rolebinding_name = "formbuilder-service-token-cache-live-dev"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  # github_repositories = ["my-repo"]
}

