module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "01-01-2000"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["justice-redact-frontend", "justice-redact-backend"]

  # This allows Staging to pull images from your central Dev ECR
  github_actions_secret_kube_ecr_credentials_allow_cross_namespace_ids = ["justice-redact-dev"]
} 